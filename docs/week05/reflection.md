# Week 5 reflection

Draft based on the current project; review the wording so it reflects your own experience before submitting.

## Which structural decision from Week 1 helped you most by Week 5?

Keeping the app split into models, data, and presentation helped the most. I could add the Steam import and SQLite storage without putting API requests or database code directly into the Library widgets. The same game data could then be used by Overview, Library, and Details.

## Which one cost you time, and what would you do differently?

Keeping the old Media Cleaner and H2 demonstrations alongside the new game app took extra care. Some old screens still had active coursework callers, so deleting them would have broken required examples. I would mark development-only screens and their dependencies earlier, then record which tests still rely on them before moving files.

## Where is your app's state right now, and what will be hard about moving it in Module 2?

The game library, selected Steam profile, and achievement notes are stored locally in SQLite. Steam game and achievement data is read from a local Worker when requested, then cached locally. The Worker is not deployed and there is no app account or cloud sync. Moving to Module 2 will require a secure deployed API, account authorization, and a clear migration and conflict policy so one user's private notes cannot appear in another account.
