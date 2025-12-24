# wow-addon-LibIconPicker

LibIconPicker is a high-performance icon selection library for World of Warcraft addons. It provides a clean, callback-based API that lets addons open an icon picker and receive the selected icon instantly — without managing UI state, layouts, or large icon lists themselves.

Designed from the ground up to be lightweight and efficient, LibIconPicker uses a hybrid scroll frame and lazy rendering so only visible icons are processed at any time. This keeps CPU usage low during scrolling and filtering, even with very large icon sets, and avoids unnecessary redraws or background work.

The UI is lazy-loaded and initialized only when needed, ensuring minimal memory usage and zero impact on addon startup time. No persistent data or saved variables are created by the library, keeping memory footprints small and predictable.

LibIconPicker is safe to embed or use standalone, supports multiple addons simultaneously, and avoids global side effects by following established WoW library conventions. The result is a fast, scalable, and memory-efficient icon picker that integrates cleanly into any addon without adding performance overhead or maintenance burden.
