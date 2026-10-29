# English theme fonts

The Flutter UI uses these bundled fonts when the app language resolves to English. Chinese and Japanese mappings are documented in `../cjk/README.md`. `fontFamilyForSkin` in `lib/app/theme/app_theme.dart` is the mapping source of truth.

| Font | Themes | Source |
| --- | --- | --- |
| Fredoka | Studio Blocks, AI Glow, Cocoa Theater | `google/fonts/ofl/fredoka/Fredoka[wdth,wght].ttf` |
| Nunito | Glass Notes, Cloud Softness, Monochrome Stroll | `google/fonts/ofl/nunito/Nunito[wght].ttf` |
| Quicksand | Soft Wellness, Forest Journal | `google/fonts/ofl/quicksand/Quicksand[wght].ttf` |

Sources: https://github.com/google/fonts/tree/main/ofl. Each font is distributed under its corresponding SIL Open Font License 1.1 in `licenses/`; keep those license files with the bundled fonts.
