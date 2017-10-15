pimodoro
========
  
## Introduction

An opimionated Vim pomodoro plugin.
  
## Optional Dependencies

* [Airline](https://github.com/bling/vim-airline): If airline is installed, the current time and stage will be shown

## Philosophy

This plugin relies on the pomodoro technique steps.

1) Decide on a task to complete.
2) Set the pomodoro timer. Usually, this is 25 minutes.
   The act of setting the timer is important, and so there is no default timer value.
3) Work on the task.
   You must explicitly start the task to again reinforce the importance of starting.
   If work is interrupted, you should complete the interruption, set a reminder, or reset the current timer in that order of preference.
4) Stop what you were doing when the timer completes. Mark down a checkmark.
5) If you have less than four checkmarks, take a 3-5 minute break then go to step 2.
6) If you have four checkmarks, take a 15-30 minute break then go to step 1.

## Configuration

`g:pim#taskfile`

A file to use to write tasks.
If defined, it will automatically be opened in a split when setting the current task.

`g:pim#enable_write_interruptions`

Open the taskfile, if it is set, when a pomodoro is interrupted.
Defaults to true.

`g:pim#enable_write_checks`

Open the taskfile, if it is set, when a pomodoro or pomodoro set is completed.
Defaults to true.

`OnPimWorkFinish()`

If defined, this function will be called when the work timer expires.

`OnPimBreakFinish()`

If defined, this function will be called when the break timer expires.

## Usage

The usage of the program follows the Pomodoro technique as if you are using a real timer.

`pim#get()`

Get a formatted string representing the current state. Update it if needed.

Ex. `:call pim#get() => [01:30/25:00][Working][1]`

`pim#set_reminder()`

Open the taskfile, if defined, and set a reminder.
This is intended to set reminders so that you are not interrupted while working, but will open the taskfile at any time.

`pim#set_task()`
`pim#set_timer('25m')` `pim#set_timer('25:00')` `pim#set_timer('1500')`
`pim#start_work()`
`pim#check_off()`
`pim#start_break('3m')` `pim#start_break('03:00')` `pim#start_break('180')`

These functions allow for explicitly completing steps in order.
You must be on the correct step for these functions to do anything.
Some steps will be automatically completed.

`:Pim <time>`

This command allows for explicitly going to the next step.
When starting work or a break, a time is required.

## Breaking the workflow

You should avoid breaking the workflow whenever possible.
These functions are made a available to break the workflow if necessary.

`pim#void()`

Void the current pomodoro and set the task again.
Reserved for mistakes and internal interruptions.

`pim#void_set()`

Void the current entire pomodoro set and set the taks again.
Reserved for the most heinous interruptions.

`pim#interrupt()`

Stop working because of an unavoidable external interruption.

`pim#mark_interruption()`

After interrupting, record the reason for interruption.
Afterwards, the timer can be set again and the pomodoro can be completed.

## Credits

Inspired by [vim-airline-tomato](https://github.com/Zuckonit/vim-airline-tomato)
