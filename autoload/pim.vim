let s:pim_file = "~/.pimodoro"

" Stage constants

let s:setting_task = 'Setting task'
let s:setting_timer = 'Setting timer'
let s:starting_work = 'Starting work'
let s:working = 'Working'
let s:interrupted = 'Interrupted'
let s:checking_off = 'Checking off'
let s:starting_break = 'Starting break'
let s:taking_short_break = 'Taking short break'
let s:taking_long_break = 'Taking long break'

" Settings

function! s:get_taskfile()
  return exists('g:pim#taskfile') ? g:pim#taskfile : ''
endfunction

function! s:get_enable_write_interruptions()
  return exists('g:pim#enable_write_interruptions') ? g:pim#enable_write_interruptions : 1
endfunction

function! s:get_enable_write_checks()
  return exists('g:pim#enable_write_checks') ? g:pim#enable_write_checks : 1
endfunction

function! s:on_work_finish()
  if exists('*OnPimWorkFinish')
    call OnPimWorkFinish()
  endif
endfunction

function! s:on_break_finish()
  if exists('*OnPimBreakFinish')
    call OnPimBreakFinish()
  endif
endfunction

" Stage utilities

function! s:set_state(stage, length, iterations)
  let state = [localtime(), a:stage, a:length, a:iterations]
  call writefile(state, expand(s:pim_file))
  return state
endfunction

function! s:get_state()
  if filereadable(expand(s:pim_file))
    return readfile(expand(s:pim_file), '')
  else
    return s:set_state(s:setting_task, 0, 0)
  endif
endfunction

function! s:process_time(time)
  try
    if match(a:time, '^\d\+:\d\+$') == 0
      let splittime = split(a:time, ':')
      let hours = str2nr(splittime[0])
      let minutes = str2nr(splittime[1])
      if minutes < 60
        return hours * 60 + minutes
      endif
    elseif match(a:time, '^\d\+[mM]$') == 0
      return str2nr(a:time) * 60
    endif
    return str2nr(a:time)
  catch
    return 0
  endtry
endfunction

" Change stages

function! pim#set_task()
  let state = s:get_state()
  if state[1] != s:setting_task
    echo 'Task already set'
  else
    let taskfile = s:get_taskfile()
    if taskfile != ''
      exec 'vsplit '.taskfile
    endif
    return s:set_state(s:setting_timer, 0, state[3])
  endif
  return state
endfunction

function! pim#set_timer(time)
  let state = s:get_state()
  if state[1] != s:setting_timer
    echo 'Not currently setting timer'
  else
    let time = s:process_time(a:time)
    if time == 0
      echo 'Working time length is required'
    else
      return s:set_state(s:starting_work, time, state[3])
    endif
  endif
  return state
endfunction

function! pim#start_work()
  let state = s:get_state()
  if state[1] != s:starting_work
    echo 'Not currently starting work'
  else
    return s:set_state(s:working, state[2], state[3])
  endif
  return state
endfunction

function! pim#set_reminder()
  let taskfile = s:get_taskfile()
  if taskfile != ''
    exec 'vsplit '.taskfile
  endif
endfunction

function! pim#interrupt()
  let state = s:get_state()
  if state[1] != s:working
    echo 'Not currently working'
  else
    return s:set_state(s:interrupted, state[2], state[3])
  endif
  return state
endfunction

function! pim#mark_interruption()
  let state = s:get_state()
  if state[1] != s:interrupted
    echo 'Not currently interrupted'
  else
    let taskfile = s:get_taskfile()
    let enable_write_interruptions = s:get_enable_write_interruptions()
    if taskfile != '' && enable_write_interruptions
      exec 'vsplit '.taskfile
    endif
    return s:set_state(s:setting_timer, 0, state[3])
  endif
  return state
endfunction

function! s:finish_work()
  let state = s:get_state()
  if state[1] != s:working
    throw 'Not currently working'
  else
    call s:on_work_finish()
    return s:set_state(s:checking_off, state[2], state[3] + 1)
  endif
  return state
endfunction

function! pim#check_off()
  let state = s:get_state()
  if state[1] != s:checking_off
    echo 'Not currently checking off'
  else
    let taskfile = s:get_taskfile()
    let enable_write_checks = s:get_enable_write_checks()
    if taskfile != '' && enable_write_checks
      exec 'vsplit '.taskfile
    endif
    return s:set_state(s:starting_break, state[2], state[3])
  endif
  return state
endfunction

function! pim#start_break(time)
  let state = s:get_state()
  if state[1] != s:starting_break
    echo 'Not currently starting break'
  else
    let time = s:process_time(a:time)
    if time == 0
      echo 'Break time length is required'
    else
      let new_stage = state[1] == 4 ? s:taking_long_break : s:taking_short_break
      return s:set_state(new_stage, a:time, state[3])
    endif
  endif
  return state
endfunction

function! s:finish_short_break()
  let state = s:get_state()
  if state[1] != s:taking_short_break 
    throw 'Not currently taking short break'
  else
    call s:on_break_finish()
    return s:set_state(s:setting_timer, 0, state[3])
  endif
  return state
endfunction

function! s:finish_long_break()
  let state = s:get_state()
  if state[1] != s:taking_long_break 
    throw 'Not currently taking long break'
  else
    call s:on_break_finish()
    return s:set_state(s:setting_task, 0, 0)
  endif
  return state
endfunction

function! pim#void()
  return s:set_state(s:setting_task, 0, state[3])
endfunction

function! pim#void_set()
  return s:set_state(s:setting_task, 0, 0)
endfunction

function! pim#next(...)
  let stage = s:get_state()[1]
  if stage == s:setting_task
    call pim#set_task()
  elseif stage == s:setting_timer
    if a:0 == 0 || !a:1
      echo 'Working time length is required'
    else
      call pim#set_timer(a:1)
    endif
  elseif stage == s:starting_work
    call pim#start_work()
  elseif stage == s:working || stage == s:taking_short_break || stage == s:taking_long_break
    echo 'The stage will be changed when the timer finishes'
  elseif stage == s:interrupted
    call pim#mark_interruption()
  elseif stage == s:checking_off
    call pim#check_off()
  elseif stage == s:starting_break
    if a:0 == 0 || !a:1
      echo 'Breeak time length is required'
    else
      call pim#start_break(a:1)
    endif
  else
    throw 'Unknown stage '.stage[1]
  endif
endfunction

" Airline utilities

function! s:format_time(time)
  return printf('%02d:%02d', a:time / 60, a:time % 60)
endfunction

function! s:format_state(remaining_time, length, stage, interval)
  let text = ''
  let text .= '['.s:format_time(a:remaining_time).'/'.s:format_time(a:length).']'
  let text .= '['.a:stage.']'
  let text .= '['.a:interval.']'
  return text
endfunction

function! s:incremented_state()
  let state = s:get_state()
  let start_time = state[0]
  let stage = state[1]
  let length = state[2]

  if stage == s:working || stage == s:taking_short_break || stage == s:taking_long_break
    let remaining_time = max([length - (localtime() - start_time), 0])
    if remaining_time <= 0
      if stage == s:working
        let state = s:finish_work()
      elseif stage == s:taking_short_break
        let state = s:finish_short_break()
      elseif stage == s:taking_long_break
        let state = s:finish_long_break()
      endif
    endif
  else
    let remaining_time = 0
  endif

  return state + [remaining_time]
endfunction

function! pim#get() abort
  let state = s:incremented_state()
  let start_time = state[0]
  let stage = state[1]
  let length = state[2]
  let interval = state[3]
  let remaining_time = state[4]

  return s:format_state(remaining_time, length, stage, interval)
endfunction

" Commands

command -nargs=? Pim call pim#next(<q-args>)
