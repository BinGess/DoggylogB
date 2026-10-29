# Chinese and Japanese theme fonts

`fontFamilyForSkin` and `headingFontFamilyForSkin` in `lib/app/theme/app_theme.dart` set body and heading fonts when the app language is Chinese or Japanese. The original LXGWWenKai remains a fallback for missing characters. Heading-only display faces are not used for the small task and settings text.

| Themes | Chinese body / heading | Japanese body / heading |
| --- | --- | --- |
| 积木学堂、AI 对话、可可剧场 | Xiaolai / ZCOOL KuaiLe | Zen Maru Gothic / Hachi Maru Pop |
| 数据透明、黑白漫游 | LXGW WenKai / Xiaolai | Zen Maru Gothic / Zen Maru Gothic |
| 云朵温柔 | Xiaolai / Xiaolai | Zen Maru Gothic / Zen Maru Gothic |
| 健康轻灵 | LXGW WenKai / LXGW WenKai | M PLUS Rounded 1c / M PLUS Rounded 1c |
| 林间手账 | ZCOOL XiaoWei / ZCOOL XiaoWei | M PLUS Rounded 1c / M PLUS Rounded 1c |

Xiaolai v3.126: https://github.com/lxgw/kose-font/releases/tag/v3.126

Other font binaries: https://github.com/google/fonts/tree/main/ofl (families `zcoolkuaile`, `zcoolxiaowei`, `zenmarugothic`, `roundedmplus1c`, `hachimarupop`). Each included binary has its own SIL Open Font License in `licenses/`; retain the licenses when redistributing the app.
