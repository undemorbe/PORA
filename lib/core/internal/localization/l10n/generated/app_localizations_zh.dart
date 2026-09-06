// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Pora';

  @override
  String get language => '语言';

  @override
  String get authUnderAppName1 => '情侣和家庭共享清单';

  @override
  String get authUnderAppName2 => '食谱、家庭采购和配送，一站搞定';

  @override
  String get onlyYou => '仅你';

  @override
  String get authSignInExpansibleExpand => '使用其他方式登录';

  @override
  String get authSignInExpansibleCollapse => '收起';

  @override
  String get sendAgainAfter => '重新发送，倒计时…';

  @override
  String get authSignInWithEmail => '使用邮箱登录';

  @override
  String get authSignInWithGoogle => '使用 Google 登录';

  @override
  String get authSignInWithApple => '使用 Apple 登录';

  @override
  String get authSignInWithPhone => '使用手机号登录';

  @override
  String get authPrivatePolicy =>
      'By continuing, 你 agree 到 \\nTerms 和 Privacy Policy';

  @override
  String get authTitle => '快完成了';

  @override
  String get authSubtitle =>
      '输入 你的 电话 number 或 邮箱 — we\'ll send 你 a sign-在 代码.';

  @override
  String get authSubtitle2 =>
      'Start typing — we\'ll detect whether it\'s a 电话 number 或 邮箱.';

  @override
  String get authJoinButton => '加入';

  @override
  String get userCreateProfileNameRequired => 'How about telling us 你的 名称?';

  @override
  String get commonError => '错误';

  @override
  String get authErrorInvalidPhone => 'Invalid 电话 / 邮箱!';

  @override
  String authPhoneSendOtp(String isPhone) {
    String _temp0 = intl.Intl.selectLogic(isPhone, {
      'true': 'Telegram!',
      'false': 'email!',
      'other': 'destination you wrote',
    });
    return 'We\'ll send 代码 onto $_temp0';
  }

  @override
  String get otpTitle => '快完成了！';

  @override
  String get otpEnterCodeSentTo => '输入  代码 已发送 到 ';

  @override
  String get otpResendQuestion => 'Didn\'t receive  代码?';

  @override
  String get otpResend => '重新发送';

  @override
  String get otpVerifyButton => 'Verify 代码';

  @override
  String get otpValidationLength => '输入  6-digit 代码';

  @override
  String get otpValidationDigits => ' 代码 contains digits only';

  @override
  String get authSwitchToEmail => '使用邮箱登录';

  @override
  String get authSwitchToPhone => '使用手机号登录';

  @override
  String onboardingStep(int step, int total) {
    return '第 $step 步，共 $total 步';
  }

  @override
  String get onboardingSlide1Title => '食谱 → 清单\\nin seconds';

  @override
  String get onboardingSlide1Body =>
      'Drop a 食谱 link — Pora collects  食材 和 removes what 你 已经 有.';

  @override
  String get onboardingSlide2Title => '一 清单\\nfor 二';

  @override
  String get onboardingSlide2Body =>
      'Add things together — 你 可以 see who 已添加 what. 你的 partner 可以 pick up what 你 need 在  way home.';

  @override
  String get onboardingSlide3Title => 'Pora 知道\n什么时候该买';

  @override
  String get onboardingSlide3Body =>
      'Based 在 你的 purchases, Pora predicts what 将 run out 很快 和 lets 你 订单 it 和 一 点击.';

  @override
  String get onboardingSkip => '跳过';

  @override
  String get onboardingStart => '开始';

  @override
  String get onboardingNext => '下一步';

  @override
  String get splashTagline => ' 清单 that remembers 用于 你';

  @override
  String get briefTitle => 'What do 你 often run out of?';

  @override
  String get briefDeletionTitle => '是 你 sure 你 want 到 删除 这个 商品?';

  @override
  String get briefAddYourOwn => '添加';

  @override
  String get briefInputProduct => '输入 a 商品 或 category';

  @override
  String get briefInputEmoji => '输入 an emoji/icon 用于  商品';

  @override
  String get briefAlreadyContains => '这个 商品 是 已经 已选择';

  @override
  String get briefSubtitle =>
      '选择 商品 — Pora 将 remind 你 at  right time. 你 可以 skip 这个.';

  @override
  String get briefSkip => '跳过';

  @override
  String get briefNext => '下一步';

  @override
  String get briefItemMilk => '牛奶';

  @override
  String get briefItemBread => '面包';

  @override
  String get briefItemEggs => '鸡蛋';

  @override
  String get briefItemCoffee => '咖啡';

  @override
  String get briefItemCheese => '奶酪';

  @override
  String get briefItemBananas => '香蕉';

  @override
  String get briefItemButter => '黄油';

  @override
  String get briefItemWater => '水';

  @override
  String get briefItemVegetables => '蔬菜';

  @override
  String get briefItemTomatoes => '番茄';

  @override
  String get briefItemPasta => '意面';

  @override
  String get briefItemChicken => '鸡肉';

  @override
  String get listTitle => '我们的清单';

  @override
  String get listMembersCount => '2 人 · 8 商品';

  @override
  String get listUrgent => '紧急';

  @override
  String get listAdd => '添加';

  @override
  String get predictionsTitle => 'Pora 可以 help!';

  @override
  String get predictionsSubtitle => 'Running out 很快 — based 在 你的 purchases';

  @override
  String get predictionTip => '小提示';

  @override
  String get predictionsOrderTitle => '订单 everything 和 一 点击';

  @override
  String get predictionsOrderSubtitle => 'Samokat · 配送 在 15 分钟';

  @override
  String get predictionsOrderDiscount => '15% off 你的 first 订单';

  @override
  String get predictionsAddToList => 'Add 到 清单';

  @override
  String get predictionsDismiss => '没有 thanks';

  @override
  String get itemDetailName => '牛奶';

  @override
  String get itemDetailSubtitle => '2 L · 乳制品';

  @override
  String get itemDetailAddedBy => '已添加 by';

  @override
  String get itemDetailSection => '分类';

  @override
  String get itemDetailSectionValue => '乳制品';

  @override
  String get itemDetailQuantity => '数量';

  @override
  String get itemDetailQuantityValue => '2 L';

  @override
  String get itemDetailUrgent => '紧急';

  @override
  String get itemDetailRemind => '提醒我';

  @override
  String get itemDetailRemindEvery => 'Every 7 天';

  @override
  String get itemDetailInsight =>
      '你 buy it about every 7 天 · last bought 6 天 ago. I\'ll suggest restocking 很快.';

  @override
  String get itemDetailMarkBought => '标记为已购买';

  @override
  String get itemDetailDelete => '移除 来自 清单';

  @override
  String get addItemTitle => 'Add 商品';

  @override
  String get addItemExampleValue => '牛油果';

  @override
  String get addItemNameHint => '商品 名称';

  @override
  String get addItemQuantity => '数量';

  @override
  String get addItemSection => '分类';

  @override
  String get addItemUrgent => '紧急';

  @override
  String get addItemUrgentSubtitle => 'Need 到 buy 今天';

  @override
  String get addItemRemind => '定期提醒';

  @override
  String get addItemRemindEvery => 'Every 7 天';

  @override
  String get addItemSubmit => 'Add 到 清单';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsHouseholdSection => '家庭';

  @override
  String get settingsAppSection => '应用';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsDelivery => '配送';

  @override
  String get settingsProAd => 'Pora+ · ad-免费';

  @override
  String get settingsTryPill => '试用';

  @override
  String get settingsPrivacy => '隐私与数据';

  @override
  String get settingsAboutPora => '关于 Pora';

  @override
  String get settingsLogout => '退出登录';

  @override
  String get settingsMembersNames => 'Boris 和 Anna';

  @override
  String get settingsInvitePill => '邀请';

  @override
  String get householdInviteTitle => 'Invite 你的 partner';

  @override
  String get householdCookTogether => '一起做饭';

  @override
  String get householdInviteDescription =>
      'Pora works better 用于 二. Invite 你的 partner — 你的 清单 和 reminders 将 be 共享.';

  @override
  String get householdShareLink => '分享链接';

  @override
  String get householdShowQr => '显示二维码';

  @override
  String get householdConnectToFamily => '加入家庭';

  @override
  String get householdInviteDescriptionWhenConnecting =>
      'We detected an invite 代码, but 你 可以 enter it yourself if we got it wrong';

  @override
  String get householdGotInvited => '你\'ve been invited 到 a 家庭';

  @override
  String get householdWriteCode => '输入 invite 代码';

  @override
  String get householdDoLater => '我稍后再做';

  @override
  String get householdCopyCode => '已复制到剪贴板！';

  @override
  String get householdInviteCodeLabel => '邀请码';

  @override
  String get householdCopyPill => '复制';

  @override
  String get notificationsTitle => '通知';

  @override
  String get notificationsReadAll => '全部已读';

  @override
  String get notificationsMilkTitle => 'Grab 牛奶 在 你的 way home';

  @override
  String get notificationsMilkBody =>
      'It\'s run out — Anna marked it 10 分钟 ago.';

  @override
  String get notificationsMilkTime => '5 分钟 ago';

  @override
  String get notificationsCoffeeTitle => '咖啡 是 running out 很快';

  @override
  String get notificationsCoffeeBody =>
      '你 buy it about every 14 天, 12 有 passed.';

  @override
  String get notificationsPartnerAddedTitle => 'Anna 已添加 2 商品';

  @override
  String get notificationsPartnerAddedBody => '香蕉 和 面包 是 在  共享 清单.';

  @override
  String get notificationsPartnerAddedTime => '今天, 9:12';

  @override
  String get notificationsPromoTitle => '15% off 你的 first Samokat 订单';

  @override
  String get notificationsPromoBody => ' promo 是 active 用于 6 more 天.';

  @override
  String get notificationsPromoTime => '昨天';

  @override
  String get notificationsOrderDeliveredTitle => '订单 delivered';

  @override
  String get notificationsOrderDeliveredBody => '8 商品 · Samokat · ₽1,054';

  @override
  String get notificationsAddToListPill => '＋ Add 到 清单';

  @override
  String get userCreateProfileTitle => 'What\'s 你的 名称?';

  @override
  String get userCreateProfileSubtitle =>
      'Add a 名称 和 照片 — 你的 partner 将 see them 在  共享 清单.';

  @override
  String get userCreateProfileNameHint => '你的 名称';

  @override
  String get userCreateProfileSkip => '跳过';

  @override
  String get userCreateProfileNext => '下一步';

  @override
  String get searchTitle => '搜索';

  @override
  String get searchHint => '商品 或 食谱…';

  @override
  String get searchFilterAll => '全部';

  @override
  String get searchFilterVegetables => '蔬菜';

  @override
  String get searchFilterDairy => '乳制品';

  @override
  String get searchFilterGrocery => '杂货';

  @override
  String get searchFilterRecipes => '食谱';

  @override
  String get searchResults => '结果';

  @override
  String get searchNothingFound => '未找到内容';

  @override
  String get insightsTitle => '洞察';

  @override
  String get insightsTipKicker => '✨ PORA 提示';

  @override
  String get insightsTipTitle => '你 love carbonara!';

  @override
  String get insightsTipBody =>
      'Similar flavor profile — try mac 和 奶酪. 你 已经 regularly 有 4 of 6 食材.';

  @override
  String get insightsTipAction => '打开 食谱 →';

  @override
  String get insightsRunsOutMost => '最常用完';

  @override
  String get insightsFavoriteCuisines => '常吃的菜系';

  @override
  String get insightsCuisineItalian => '意大利菜';

  @override
  String get insightsCuisinePasta => '意面';

  @override
  String get insightsCuisineBreakfasts => '早餐';

  @override
  String get insightsCuisineLight => '浅色';

  @override
  String get orderTitle => '订单';

  @override
  String get orderCart => '购物车';

  @override
  String get orderWhenToDeliver => '配送时间';

  @override
  String orderCheckoutCta(String total) {
    return '订单 来自 Samokat · $total';
  }

  @override
  String get orderSummaryGoods => '商品';

  @override
  String get orderSummaryDiscount => '立减 15%';

  @override
  String get orderSummaryDelivery => '配送';

  @override
  String get orderSummaryFree => '免费';

  @override
  String get orderSummaryTotal => '合计';

  @override
  String get recipeImportTitle => '食谱 来自 a link';

  @override
  String get recipePreviewTitle => 'Pasta Carbonara';

  @override
  String get recipePreviewMeta => 'eda.ru · 25 分钟 · 2 份';

  @override
  String get recipePreviewFound => '6 食材 found';

  @override
  String get recipeDedupBanner =>
      'Removed 2 duplicates 到 avoid duplicating items 已经 在 你的 清单';

  @override
  String get recipeIngredients => '食材';

  @override
  String get recipeAddToListCta => 'Add 4 商品 到 清单';

  @override
  String get recipeParseButton => '解析';

  @override
  String get navList => '清单';

  @override
  String get navPora => 'Pora';

  @override
  String get navOrder => '订单';

  @override
  String get navProfile => '个人资料';

  @override
  String get familiesTitle => '家庭';

  @override
  String get familiesSubtitle => '选择 a 家庭 到 打开 its 清单';

  @override
  String get familiesCurrent => '当前';

  @override
  String get familiesCreateOrJoin => '＋ Create 或 join';

  @override
  String get familiesCreateDialog => 'What should we call  家庭?';

  @override
  String get tryToUpdate => '尝试刷新';

  @override
  String get checkOut => '检查';

  @override
  String get settingsMore => '高级';

  @override
  String get listsYour => '你的个人清单';

  @override
  String get human => '人';

  @override
  String get products => '件商品';

  @override
  String get lists => '个清单';

  @override
  String get update => '刷新';

  @override
  String get connectionSuccess => '已加入';

  @override
  String get familiesNoUrgent => '暂无紧急事项';

  @override
  String get welcomeBackTitle => '欢迎回来！';

  @override
  String get welcomeBackSubtitle => '一 second, opening 你的 清单…';

  @override
  String get errorDuringLoading => '加载时出错';

  @override
  String get familyName => '家庭名称';

  @override
  String get familiesCreate => '创建';

  @override
  String get familiesConnect => '加入';

  @override
  String get showAll => '查看全部';

  @override
  String get priorityLabel => '优先级';

  @override
  String get everyDay => '每天';

  @override
  String get newList => '新清单';

  @override
  String get listNamePlaceholder => '清单名称';

  @override
  String get cancel => '取消';

  @override
  String get quantityLabel => '数量';

  @override
  String get personal => '个人';

  @override
  String get notify => '通知';

  @override
  String get notifyEveryone => '所有人';

  @override
  String get notifyRecipients => '发送给';

  @override
  String get notifyAddCustom => '添加姓名';

  @override
  String get notifyMessageLabel => '消息';

  @override
  String notifyHint(String itemName) {
    return '紧急购买 $itemName';
  }

  @override
  String get notifySend => '发送';

  @override
  String get notifySent => '通知已发送';

  @override
  String get advancedSettings => '高级设置';

  @override
  String get appearance => '外观';

  @override
  String get themeSection => '主题';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get notificationsPermission => '通知 permission';

  @override
  String get granted => '已允许';

  @override
  String get denied => '已拒绝';

  @override
  String get notDetermined => '未请求';

  @override
  String get requestPermission => '请求权限';

  @override
  String get confirmations => '确认';

  @override
  String get askBeforeDelete => '删除前询问';

  @override
  String get about => '关于';

  @override
  String get version => '版本';

  @override
  String get deleteItemTitle => '删除 item?';

  @override
  String get deleteItemBody => '这个 cannot be undone.';

  @override
  String get dontAskAgain => '不再询问';

  @override
  String get delete => '删除';

  @override
  String get returnToList => 'Return 到 清单';

  @override
  String get nooneToNotify => '没有 一 到 notify';

  @override
  String get notFound => '不 found';

  @override
  String get recipeEmptyHint => 'Paste a 食谱 URL 和 点击 “Parse”';

  @override
  String get recipeDupMark => '已经 在 清单';

  @override
  String get done => '完成';

  @override
  String get errorGeneric => '错误';

  @override
  String get pushToken => '推送令牌';

  @override
  String get resync => '同步';

  @override
  String get tokenSynced => '令牌已同步';

  @override
  String get deleteListTitle => '删除 清单?';

  @override
  String deleteListBody(String listName) {
    return '清单 “$listName” 和 all its items 将 be deleted. 这个 cannot be undone.';
  }

  @override
  String get membersScreenTitle => '成员';

  @override
  String get owner => '所有者';

  @override
  String get member => '成员';

  @override
  String get addProduct => 'Add 商品';

  @override
  String get productName => '名称';

  @override
  String get section => '分类';

  @override
  String get unit => '单位';

  @override
  String get priorityHigh => '高';

  @override
  String get priorityMed => '中';

  @override
  String get priorityLow => '低';

  @override
  String get urgent => '紧急';

  @override
  String get remindEvery => '提醒周期';

  @override
  String get days => '天';

  @override
  String get customValue => '自定义…';

  @override
  String get save => '保存';

  @override
  String addedByName(String name) {
    return '已添加 by: $name';
  }

  @override
  String get splashLoadingSlow => '快完成了…';

  @override
  String get splashLoadingVerySlow => '仍在加载…正在检查连接';

  @override
  String get profileNameUpdate => '正在更新资料';

  @override
  String get briefSnackBar => 'Maybe 你 forgot 到 选择 any 商品?';

  @override
  String get noInternet => '没有 internet connection';

  @override
  String get noInternetButLoadYouLocally =>
      '没有 internet connection, but we 将 load 你 locally';

  @override
  String get groupDeletionTitle => '是 你 sure want 到 删除 群组?';

  @override
  String get retry => '重试';

  @override
  String get groupsTitle => '你的群组';

  @override
  String get groupsSubtitle => 'A 清单 是 a 群组. Invite 人 — they\'ll see  清单.';

  @override
  String get groupCreate => '创建群组';

  @override
  String get groupConnect => '加入';

  @override
  String get groupNameHint => '群组名称';

  @override
  String get groupPersonal => '个人';

  @override
  String get groupShared => '共享';

  @override
  String get noGroups => '还没有群组';

  @override
  String get settingsChangeThemeIOSEasterEgg =>
      '* 到 change 你的 主题, go 到 设置 > PORA > 主题\n* 选择 a new 主题 来自  设置 menu\n* 点击 在 \'主题\' 在  app\'s 设置 到 switch between 浅色 和 深色 modes';

  @override
  String get tutorialTitle => '使用方法';

  @override
  String get tutorialSkip => '跳过';

  @override
  String get tutorialNext => '下一步';

  @override
  String get tutorialDone => '开始';

  @override
  String get tutorialInviteTitle => 'Invite 你的 人';

  @override
  String get tutorialInviteBody =>
      '滑动 a 群组 right → Invite. 你的 partner sees  same 清单.';

  @override
  String get tutorialAddTitle => 'Add a 商品';

  @override
  String get tutorialAddBody =>
      '点击 + at  bottom of  清单. 名称, qty, 分类, priority — done.';

  @override
  String get tutorialEditTitle => 'Edit 和 check off';

  @override
  String get tutorialEditBody =>
      '点击  checkbox — bought. 点击  row — details 和 edits.';

  @override
  String get tutorialDeleteTitle => '删除';

  @override
  String get tutorialDeleteBody =>
      '滑动 a 商品 left → 删除. Confirmation 可以 be turned off.';

  @override
  String get tutorialAiTitle => 'Import a 食谱';

  @override
  String get tutorialAiBody =>
      'Paste a 食谱 URL, 点击 Parse. 食材 drop into  清单, duplicates marked.';

  @override
  String get tutorialSettingsTitle => 'Everything 在 reach';

  @override
  String get tutorialSettingsBody =>
      '主题, language, 通知, confirmations — Profile → Advanced 设置.';

  @override
  String get showTutorial => '查看教程';

  @override
  String get tutorialSampleGroupFamily => '家庭';

  @override
  String get tutorialSampleMilk => '牛奶';

  @override
  String get tutorialSampleBread => '面包';

  @override
  String get tutorialSampleAvocado => '牛油果';

  @override
  String get tutorialSampleMilkQty => '牛奶 2×1L';

  @override
  String get tutorialSampleCoffee => '咖啡';

  @override
  String get tutorialSampleCola => '可乐';

  @override
  String get tutorialSampleRecipeUrl => 'recipe.example/pasta';

  @override
  String get tutorialSampleIngredient1 => 'Spaghetti 400 g';

  @override
  String get tutorialSampleIngredient2 => '番茄 500 g';

  @override
  String get tutorialSampleIngredient3 => 'Garlic 3 cloves';

  @override
  String get tutorialSampleToggleTheme => '主题';

  @override
  String get tutorialSampleToggleNotif => '通知';

  @override
  String get tutorialSampleToggleConfirm => '确认';

  @override
  String get tutorialConnectTitle => 'Join by 代码';

  @override
  String get tutorialConnectBody =>
      'Partner sends a link 或 代码. Paste it — 你\'re 在  共享 清单.';

  @override
  String get tutorialNotifyTitle => '提醒「现在需要」';

  @override
  String get tutorialNotifyBody =>
      '点击 «!» 在 a 商品 — 你的 partner gets a push «buy it now». 没有 calls needed.';

  @override
  String get tutorialOutroTitle => '你\'ll figure out  rest';

  @override
  String get tutorialOutroBody =>
      '点击, 滑动, mess up —  app forgives almost anything.';

  @override
  String get tutorialSampleInviteCode => 'PORA-4F72';

  @override
  String get tutorialSamplePushSender => 'Anna';

  @override
  String get tutorialSamplePushBody => 'Need 牛奶, 紧急';

  @override
  String get tutorialSampleInviteMessage => 'Join  清单';

  @override
  String get supportMessage => '邮箱 支持';

  @override
  String get supportMessageBottomSheetTopDescription =>
      '你的 消息 将 be 已发送 到  支持 team. Please provide as much detail as possible.';

  @override
  String get supportMessageBottomSheetSendButton => '发送';

  @override
  String get supportMessageBottomSheetUnderButtonText =>
      'We 将 answer as 很快 as possible, 和 mail 到 你的 gmail 或 inapp!';

  @override
  String get allergen => '过敏原';

  @override
  String get predictionsGreeting => '你的 天 和 PORA';

  @override
  String get predictionsGreetingSub => 'Smart hints 来自 你的 purchases';

  @override
  String get predictionsSectionSoon => 'Running out 很快';

  @override
  String get predictionsSectionOften => '你 buy often';

  @override
  String get predictionsSectionAiSuggests => 'AI 推荐';

  @override
  String get predictionsAiSuggestionsTitle => '商品 和 食谱 用于 你';

  @override
  String get predictionsAiSuggestionsTopic => '你的 preferences 和 purchases';

  @override
  String get refresh => '刷新';

  @override
  String get predictionsOftenEmpty => '不 enough data yet';

  @override
  String get predictionsAskPora => '询问 PORA';

  @override
  String get kpiWeek => 'items per 周';

  @override
  String get kpiRecipes => '食谱 这个 月';

  @override
  String get kpiDaysToRun => '天 until restock';

  @override
  String get fallbackTip1 =>
      '保存 herbs like a bouquet: 在 a glass of 水 covered 和 a bag — lasts 2 weeks.';

  @override
  String get fallbackTip2 => 'Add 盐 到 dough at  end — it slows down yeast.';

  @override
  String get fallbackTip3 =>
      '到 stop onions stinging, chill them 用于 15 分钟 在  freezer 之前 cutting.';

  @override
  String get fallbackTip4 =>
      'Oversalted soup? A raw potato 用于 10 分钟 soaks up  extra 盐.';

  @override
  String get fallbackTip5 =>
      'Check egg freshness 在 水: sinks — 新鲜, floats — discard.';

  @override
  String get fallbackTip6 =>
      'Reheat pizza 在 a covered skillet —  crust crisps back up.';

  @override
  String get fallbackTip7 =>
      '冷冻 meat slices thinner — 20 分钟 在  freezer 之前 cutting.';

  @override
  String get fallbackTip8 =>
      'Roll a lemon 在  counter 之前 cutting — 你\'ll get more juice.';

  @override
  String get fallbackTip9 => 'A pinch of 糖 在 tomato sauce cuts  acidity.';

  @override
  String get fallbackTip10 =>
      '面包 keeps a 月 在  freezer; toasting it goes straight 来自 冷冻.';

  @override
  String get aiTipOfDayLabel => 'TIP OF  天';

  @override
  String get aiTipOfDayTopic => '今天';

  @override
  String get aiCtaTitle => '询问 PORA';

  @override
  String get aiCtaSubtitle => '食谱 · swaps · tips';

  @override
  String get chatSheetTitle => 'PORA';

  @override
  String get chatSheetSubtitle => '询问食物、采购和替代方案';

  @override
  String get chatEmptyTitle => '开始对话';

  @override
  String get chatEmptyExamplesLabel => '示例问题：';

  @override
  String get chatSample1 => '我可以做什么 cook 和 鸡肉 和 米饭?';

  @override
  String get chatSample2 => 'What 可以 替代 sour cream 在 dough?';

  @override
  String get chatSample3 => '如何 保存 herbs so they don\'t wilt?';

  @override
  String get chatSample4 => '快速 20-分钟 晚餐 食谱';

  @override
  String get chatSample5 => '我怎样才能 use up 蔬菜 之前 they spoil?';

  @override
  String get chatSample6 => '制作一个 shopping 清单 用于 3 简单 breakfasts';

  @override
  String get chatSample7 => '我应该 cook 用于 二 和 a 小 budget?';

  @override
  String get chatSample8 => 'How long 可以 I 保存 熟的 米饭 在  fridge?';

  @override
  String get chatSample9 => '给我 a 高-protein 素食 晚餐';

  @override
  String get chatSample10 => 'What 可以 替代 黄油 在 这个 食谱?';

  @override
  String get chatSample11 => '规划三个 dinners 来自 what I 已经 有';

  @override
  String get chatSample12 => '我可以做什么 cook 和 剩菜 在 15 分钟?';

  @override
  String get chatSample13 => '推荐一个 适合过敏者 食谱 来自 my 清单';

  @override
  String get chatSample14 => '我怎样才能 make 这个 meal 更便宜?';

  @override
  String get chatTyping => 'PORA 是 typing…';

  @override
  String get chatInputHint => '随便问…';

  @override
  String get aiModelBadge => 'Powered by OpenRouter · ling-3.0-flash';

  @override
  String get seeAll => '查看全部';

  @override
  String get tipTopicHerbs => '香草';

  @override
  String get tipTopicBaking => '烘焙';

  @override
  String get tipTopicSoups => '汤';

  @override
  String get tipTopicMeat => '肉类';

  @override
  String get tipTopicFish => '鱼类';

  @override
  String get tipTopicVegetables => '蔬菜';

  @override
  String get tipTopicStorage => '食物保存';

  @override
  String get tipTopicKitchenHacks => '厨房技巧';

  @override
  String get tipTopicSpices => '香料';

  @override
  String get tipTopicDough => '面团';

  @override
  String get tipTopicBreakfast => '早餐';

  @override
  String get tipTopicDinner => '晚餐';

  @override
  String get tipTopicsSectionTitle => '提示主题';

  @override
  String get tipTopicsSectionDescription => 'Pick which topics  tip 是 drawn 来自';

  @override
  String get tipTopicsAddCustom => 'Add 你的 own topic';

  @override
  String get tipTopicsCustomLabel => '自定义';

  @override
  String get tipTopicsPredefinedLabel => '预设';

  @override
  String get tipTopicsEmpty => '没有 topics 已选择 — tip 将 be generic';

  @override
  String get insightsChampionKicker => 'CHAMPION OF  月';

  @override
  String insightsChampionSubtitle(int count) {
    return 'bought $count 次 这个 月';
  }

  @override
  String insightsStreakDays(int days) {
    return '$days 天 在 a row';
  }

  @override
  String get insightsStreakSubtitle => '你\'re 在 it — 保存 going';

  @override
  String insightsFreqEvery(int days) {
    return '~每 $days 天';
  }

  @override
  String get insightsPopular => '你 buy often';

  @override
  String get insightsStatsProducts => '件商品';

  @override
  String get insightsStatsLoginsWeek => 'logins 这个 周';

  @override
  String get insightsEmpty => '没有 data yet — start adding 商品';

  @override
  String get notificationsFilterAll => '全部';

  @override
  String get notificationsFilterUrgent => '紧急';

  @override
  String get notificationsFilterPrediction => '预测';

  @override
  String get notificationsFilterPromo => '促销';

  @override
  String get notificationsFilterOther => '其他';

  @override
  String get notificationsClearAll => '全部清除';

  @override
  String get notificationsDelete => '删除';

  @override
  String get notificationsGroupToday => '今天';

  @override
  String get notificationsGroupYesterday => '昨天';

  @override
  String get notificationsEmptyTitle => '一切安静';

  @override
  String get notificationsEmptyBody => 'New 通知 将 appear here';

  @override
  String get recipeCreateListCta => '要把这个食谱添加到哪里？';

  @override
  String get recipeDupForceMark => '仍会添加';

  @override
  String recipeDedupBannerMany(int n) {
    return '$n duplicates 将 be skipped — uncheck 到 force-add';
  }

  @override
  String get offlineWriteBlocked => '没有 internet — change won\'t be saved';

  @override
  String get offlineReadBanner => '离线 — 正在显示缓存数据';

  @override
  String get chatImportRecipeCta => '导入食谱';

  @override
  String get listsEmptyTitle => '您还没有任何列表';

  @override
  String get listsEmptySubtitle => '要不要创建一个新的？';
}
