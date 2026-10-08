# Week 03: Design

I chose blue as the seed colour for Media Cleaner because the main users are students and content creators with 64–128 GB phones who need to find large files and decide what to remove. Blue marks the buttons and selected files, so users can see what they are about to act on. The backgrounds stay neutral to keep file names and sizes easy to read. Delete uses red so it is easier to tell apart from the other actions. Media Cleaner is an independent storage tool, and the aim is to help users understand what takes up space instead of deleting random files.

Both screens use Source Sans 3, with regular text for names and details and heavier text for headings and folder sizes. The colours, text styles and button shapes come from one shared theme, so the overview and file manager look like parts of the same app.

The overview uses a bubble map inspired by my own mac app (also on my Git). Larger folders get larger circles, while very small folders stay big enough to tap. Video folders use lavender, photo folders use green, and duplicates use grey. These colours are repeated in the folder list so users can match a circle to its folder. Tapping either opens the files inside. The map shows the demo media folders, not everything stored on the phone.

The folder list has tighter rows and light separators to make it easier to compare folders. File counts use lighter text, while the sizes use heavier text and line up on the right. The small blue bars show how much of the demo media storage each folder takes up.

## H3: Component audit

The media tile used a GestureDetector and a styled Container as a button. I replaced them with a Material Card and InkWell, so tapping a file now gives ripple feedback and the tile can be selected with a keyboard. The drawn selection circles were replaced with Checkbox. Tapping the box or the rest of the tile changes the same selection, and the whole tile reports whether it is checked for screen readers. The custom rounded size label was replaced with Chip, while keeping SizeBadge as the small widget used by the tiles and storage header.

The other controls already use Material components: ChoiceChip for categories, IconButton for sorting, TextButton and FilledButton for cleanup actions, OutlinedButton for reviewing files, ListTile for folders, and SnackBar for messages. There are no custom dialogs or toasts to replace. The bubble map stays custom because Material does not provide this storage diagram; its tap feedback already uses Material and InkWell.
