# CalendarSummary

This is a personal time management application. It works great with <a href="https://en.wikipedia.org/wiki/Pomodoro_Technique">pomodoro</a> technique.

---

Long time ago I started tracking the time of my projects on a calendar like this

<img width="512" alt="image" src="https://github.com/MiklinMA/CalendarSummary/assets/37439522/73dd1cd7-ac54-426a-901d-0ace95f6eee6">


So I created an application which helps understanding how much time I spend on each task. 

<img width="444" alt="image" src="https://github.com/MiklinMA/CalendarSummary/assets/37439522/5d284da3-f615-4e9c-82a7-31d7b45d066f">


The application uses 'dot and space' ('. ') as a separator to build hierarchy. For example if you create a few events like this
* 'Project. Task 1. Subtask 1' duration 60 minutes
* 'Project. Task 1. Subtask 2' duration 30 minutes
* 'Project. Task 2. Subtask 1' duration 30 minutes

the app will create hierarchy:
<pre>
Project        2:00
- Task 1       1:30
  - Subtask 1  1:00
  - Subtask 2  0:30
- Task 2       0:30
  - Subtask 1  0:30
</pre>

You can rename multiple calendar events at once

<img width="444" alt="image" src="https://github.com/MiklinMA/CalendarSummary/assets/37439522/7042d97a-8da9-4856-a332-00449174b2f1">

Any changes on calendar will automatically update an application (via EKEventStoreChanged)


If you enable access to <a href="CalendarSummary/Extensions/AppleScript.swift">AppleScript</a>, a click on a magnifying glass (🔍) icon will open a calendar with search on the selected item.

<img width="512" alt="image" src="https://github.com/MiklinMA/CalendarSummary/assets/37439522/0427a9af-647e-40a6-89ac-61a460a3da68">
