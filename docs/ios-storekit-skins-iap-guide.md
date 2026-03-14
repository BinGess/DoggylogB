# iOS StoreKit 皮肤内购配置清单

更新日期：2026-03-14

适用范围：
- `DoggyLog` iOS App
- 第 3 套皮肤：`doggylog.skin.soft_wellness`
- 第 4 套皮肤：`doggylog.skin.cloud_softness`

## 1. 这次内购方案

当前代码已将可见皮肤中的第 3 套和第 4 套定义为单独购买后才可使用的非消耗型内购：

| 皮肤顺序 | 皮肤主题 | Product ID | 类型 | 建议价格 |
| --- | --- | --- | --- | --- |
| 第 3 套 | 健康轻灵 | `doggylog.skin.soft_wellness` | Non-Consumable | 3 元档 |
| 第 4 套 | 云朵温柔 | `doggylog.skin.cloud_softness` | Non-Consumable | 3 元档 |

为什么用 Non-Consumable：
- 用户购买一次后永久解锁
- 没有时效，不需要订阅
- 支持 Apple 标准“恢复购买”

## 2. App Store Connect 配置步骤

前提检查：
- Paid Apps Agreement 已接受
- 税务和银行信息已完善
- App 已开启 In-App Purchase 能力

在 App Store Connect 中：

1. 打开 App 对应页面。
2. 进入 `Monetization` -> `In-App Purchases`。
3. 点击 `+` 创建商品。
4. 类型选择 `Non-Consumable`。
5. 分别创建下面两个商品。

### 商品 A

- Reference Name: `Skin 3 Soft Wellness`
- Product ID: `doggylog.skin.soft_wellness`
- Price: 选择人民币 3 元对应 price tier
- Availability: 全量可售地区

建议本地化内容：
- 简体中文名称：`解锁皮肤：健康轻灵`
- 简体中文描述：`永久解锁“健康轻灵”主题皮肤，购买后可在应用内自由切换使用。`
- English Name: `Unlock Skin: Soft Wellness`
- English Description: `Permanently unlock the Soft Wellness theme skin for use in the app.`
- Japanese Name: `スキン解放：やわらかウェルネス`
- Japanese Description: `やわらかウェルネスのテーマスキンを恒久的に解放し、アプリ内で利用できます。`

### 商品 B

- Reference Name: `Skin 4 Cloud Softness`
- Product ID: `doggylog.skin.cloud_softness`
- Price: 选择人民币 3 元对应 price tier
- Availability: 全量可售地区

建议本地化内容：
- 简体中文名称：`解锁皮肤：云朵温柔`
- 简体中文描述：`永久解锁“云朵温柔”主题皮肤，购买后可在应用内自由切换使用。`
- English Name: `Unlock Skin: Cloud Softness`
- English Description: `Permanently unlock the Cloud Softness theme skin for use in the app.`
- Japanese Name: `スキン解放：くもやわらか`
- Japanese Description: `くもやわらかのテーマスキンを恒久的に解放し、アプリ内で利用できます。`

## 3. App 内触达路径

审核员需要能够在 App 内看到并触发内购。当前实现路径如下：

1. 打开 App
2. 进入底部 `我的 / Me`
3. 进入 `给小狗换装 / Dress up your pup`
4. 在皮肤列表中看到：
   - 前两套为免费可直接使用
   - 第 3 / 第 4 套显示 `¥3 解锁`
5. 点击 `¥3 解锁` 后拉起系统购买弹窗
6. 成功购买后皮肤自动解锁并切换
7. 页面顶部支持 `恢复购买`

## 4. 提审前检查

提审前建议逐项确认：

- 两个 Product ID 与代码完全一致
- 内购状态为 `Ready to Submit` 或后续可审核状态
- 购买入口在提审包中真实可见
- 点击锁定皮肤能看到系统支付弹窗
- 恢复购买按钮可见
- 截图或描述里没有暗示“全部皮肤免费”
- App 内说明与 App Store 元数据保持一致

## 5. StoreKit / Sandbox 测试建议

开发阶段建议分两种测试：

### 本地 StoreKit 测试

适合：
- 快速联调 UI
- 验证商品展示
- 验证购买成功后解锁状态

建议在 Xcode 中创建一个 `.storekit` 配置文件，至少包含以下两个商品：

- `doggylog.skin.soft_wellness`
- `doggylog.skin.cloud_softness`

本地测试建议场景：
- 正常购买成功
- 恢复购买成功
- 商品不可用
- 购买取消
- 购买 pending

### Sandbox 测试

适合：
- 用真实 App Store Connect 商品信息验证
- 验证多语言价格显示
- 验证 TestFlight 路径

注意：
- App Store Connect 商品元数据改动后，Sandbox 最多可能需要约 1 小时才生效
- TestFlight 内购走 Sandbox，不会真实扣费

## 6. 截图文案建议

因为 App Review Guidelines 要求如果截图里出现的功能包含额外付费项，就应明确说明，所以建议至少准备 1 张皮肤页截图，并在图中或图注里明确“部分皮肤需内购解锁”。

### 中文截图文案

适合放在截图副标题或宣传文案：

- `前两套皮肤免费使用，第 3 / 第 4 套支持 3 元解锁`
- `购买后永久解锁高级皮肤，并支持恢复购买`
- `自由切换主题风格，把记录界面变成更喜欢的样子`

如果要更短一些：

- `部分皮肤需内购解锁`
- `高级皮肤 3 元永久解锁`

### 英文截图文案

- `The first two skins are free. Skins 3 and 4 unlock for RMB 3 each.`
- `Premium skins unlock permanently and support Restore Purchases.`
- `Switch the app mood with premium visual skins.`

短版：

- `Some skins require in-app purchase`
- `Premium skins unlock permanently`

### 日文截图文案

- `最初の 2 つのスキンは無料、3 つ目と 4 つ目は各 3 元で解放`
- `購入後は恒久的に利用でき、購入の復元にも対応`
- `好みに合わせてアプリの見た目を切り替えられます`

短版：

- `一部スキンはアプリ内課金が必要`
- `プレミアムスキンを恒久解放`

## 7. 审核备注模板

下面这段可以直接放进 `Notes for Review`，按需微调。

### 中文版

```text
本版本新增了 2 个非消耗型应用内购买项目，用于解锁应用内的高级皮肤。

审核路径：
1. 打开 App
2. 进入底部“我的”
3. 点击“给小狗换装”
4. 第 3 套和第 4 套皮肤会显示“¥3 解锁”
5. 点击任一解锁按钮即可触发系统内购弹窗

说明：
- 前两套皮肤可免费使用
- 第 3 套和第 4 套皮肤为非消耗型内购，购买后永久解锁
- 页面右上区域提供“恢复购买”入口
- App 不需要登录账号，也不依赖外部服务即可完成审核

对应商品：
- doggylog.skin.soft_wellness
- doggylog.skin.cloud_softness
```

### English Version

```text
This version adds 2 non-consumable in-app purchases that unlock premium visual skins inside the app.

Review path:
1. Open the app
2. Go to the "Me" tab
3. Open "Dress up your pup"
4. The 3rd and 4th skins show a "¥3 Unlock" button
5. Tapping either button triggers the system in-app purchase sheet

Notes:
- The first two skins are free
- The 3rd and 4th skins are non-consumable purchases and unlock permanently
- A Restore Purchases entry is available on the same screen
- No login or external account is required for review

Product IDs:
- doggylog.skin.soft_wellness
- doggylog.skin.cloud_softness
```

## 8. 被拒风险点

最容易被卡的点通常是这些：

- 商品在 App Store Connect 已建，但审核员在 App 内找不到入口
- 截图展示了高级皮肤，但元数据没有说明需要额外购买
- Product ID 与代码不一致
- 提审包使用了内购代码，但商品还没提交审核
- 审核备注写得太泛，没有写清楚入口位置

## 9. 这次提交建议

建议采用下面的提交流程：

1. 先在 App Store Connect 建立两个 Non-Consumable 商品
2. 填好多语言名称、描述、价格
3. 生成一张皮肤页截图，明确标出“部分皮肤需内购解锁”
4. 在版本说明和 Review Notes 中说明前两套免费、后两套付费
5. 用 Sandbox 或 TestFlight 完整跑一遍购买与恢复购买
6. 再提交二进制和内购一起审核

## 10. 项目内对应代码

- 内购服务：`lib/features/pets/data/skin_purchase_service.dart`
- 商品映射：`lib/app/theme/app_skin_theme.dart`
- 购买入口与恢复购买：`lib/features/pets/presentation/pets_screen.dart`
- 皮肤解锁按钮：`lib/features/pets/presentation/widgets/pet_skin_gallery.dart`
- 购买拦截与解锁：`lib/features/shared/application/doggylog_providers.dart`

## 参考资料

- Create consumable or non-consumable In-App Purchases  
  https://developer.apple.com/help/app-store-connect/manage-in-app-purchases/create-consumable-or-non-consumable-in-app-purchases/
- In-App Purchase types  
  https://developer.apple.com/help/app-store-connect/reference/in-app-purchases-and-subscriptions/in-app-purchase-types
- Testing In-App Purchases with sandbox  
  https://developer.apple.com/documentation/StoreKit/testing-in-app-purchases-with-sandbox
- Overview of testing in sandbox  
  https://developer.apple.com/help/app-store-connect/test-in-app-purchases/overview-of-testing-in-sandbox
- Create a Sandbox Apple Account  
  https://developer.apple.com/help/app-store-connect/test-in-app-purchases/create-a-sandbox-apple-account/
- App Review Guidelines  
  https://developer.apple.com/app-store/review/guidelines/
