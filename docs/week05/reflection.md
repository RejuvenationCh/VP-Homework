# Week 5 reflection

## Which structural decision from Week 1 helped you most by Week 5?

Keeping the app split into models, data, and presentation helped me most. I could add Steam import and SQLite storage without putting API requests or database code inside the Library widgets. Overview, Library, and Details can use the same game data.

## Which one cost you time, and what would you do differently?

Keeping the original Media Cleaner and H2 demonstrations alongside the game app took extra care. Some old screens still had coursework callers, so removing them would have broken required examples. I would identify those screens and their dependencies earlier, then record which coursework examples still rely on them before changing the project.

## Where is your app's state right now, and what will be hard about moving it in Module 2?

The game library, selected Steam profile, achievement progress, and notes are stored locally in SQLite. Steam data is fetched from the Worker when I request an import or open achievements, then saved locally. The Worker is not deployed and the app has no account or cloud sync. Moving to Module 2 will require a deployed API, account authorization, and a migration and conflict policy that keeps each user's private notes separate.
