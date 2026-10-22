// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get language => '语言';

  @override
  String get onlyYou => '仅你';

  @override
  String get sendAgainAfter => '重新发送倒计时';

  @override
  String get authPrivatePolicy => '继续即表示你同意\n《服务条款》和《隐私政策》';

  @override
  String get authTitle => '快完成了';

  @override
  String get authSubtitle => '输入你的手机号或邮箱，我们会发送登录验证码。';

  @override
  String get authSubtitle2 => '直接输入即可，我们会自动识别是手机号还是邮箱。';

  @override
  String get authJoinButton => '加入';

  @override
  String get userCreateProfileNameRequired => '能告诉我们你的名字吗？';

  @override
  String get commonError => '错误';

  @override
  String get authErrorInvalidPhone => '手机号或邮箱无效！';

  @override
  String authPhoneSendOtp(String isPhone) {
    String _temp0 = intl.Intl.selectLogic(isPhone, {
      'true': 'Telegram！',
      'false': '邮箱！',
      'other': '你填写的地址',
    });
    return '我们会将验证码发送到$_temp0';
  }

  @override
  String get otpTitle => '快完成了！';

  @override
  String get otpEnterCodeSentTo => '请输入验证码，已发送至 ';

  @override
  String get otpResendQuestion => '没有收到验证码？';

  @override
  String get otpResend => '重新发送';

  @override
  String get otpVerifyButton => '验证';

  @override
  String get otpValidationLength => '请输入 6 位验证码';

  @override
  String get otpValidationDigits => '验证码只能包含数字';

  @override
  String get authSwitchToEmail => '使用邮箱登录';

  @override
  String get authSwitchToPhone => '使用手机号登录';

  @override
  String onboardingStep(int step, int total) {
    return '第 $step 步，共 $total 步';
  }

  @override
  String get onboardingSlide1Title => '食谱 → 清单\n只需几秒';

  @override
  String get onboardingSlide1Body => '粘贴食谱链接，Pora 会整理所需食材，并去掉你已经有的东西。';

  @override
  String get onboardingSlide2Title => '一份清单\n两人共享';

  @override
  String get onboardingSlide2Body => '一起添加商品，谁加了什么一目了然。你的伴侣可以在回家路上顺手买齐。';

  @override
  String get onboardingSlide3Title => 'Pora 知道\n什么时候该买';

  @override
  String get onboardingSlide3Body => 'Pora 会根据你的购买记录预测哪些东西快用完了，并提醒你把它们加入清单。';

  @override
  String get onboardingSkip => '跳过';

  @override
  String get onboardingStart => '开始';

  @override
  String get onboardingNext => '下一步';

  @override
  String get splashTagline => '替你记住一切的清单';

  @override
  String get briefTitle => '你经常用完哪些东西？';

  @override
  String get briefDeletionTitle => '确定要删除这个商品吗？';

  @override
  String get briefAddYourOwn => '添加';

  @override
  String get briefInputProduct => '输入商品或类别';

  @override
  String get briefInputEmoji => '为商品输入一个表情或图标';

  @override
  String get briefAlreadyContains => '该商品已选择';

  @override
  String get briefSubtitle => '选择商品，Pora 会在合适的时候提醒你。也可以跳过这一步。';

  @override
  String get briefSkip => '跳过';

  @override
  String get briefNext => '下一步';

  @override
  String get listUrgent => '紧急';

  @override
  String get listAdd => '添加';

  @override
  String get predictionsAddToList => '加入清单';

  @override
  String get predictionsDismiss => '不用了';

  @override
  String get itemDetailAddedBy => '添加者';

  @override
  String get itemDetailQuantity => '数量';

  @override
  String get itemDetailUrgent => '紧急';

  @override
  String get itemDetailRemind => '提醒我';

  @override
  String get itemDetailMarkBought => '标记为已购买';

  @override
  String get itemDetailDelete => '从清单中移除';

  @override
  String get addItemQuantity => '数量';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsAppSection => '应用';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsPrivacy => '隐私与数据';

  @override
  String get settingsAboutPora => '关于 Pora';

  @override
  String get settingsLogout => '退出登录';

  @override
  String get settingsInvitePill => '邀请';

  @override
  String get householdInviteTitle => '邀请你的伴侣';

  @override
  String get householdCookTogether => '一起做饭';

  @override
  String get householdInviteDescription => '两个人用 Pora 更方便。邀请你的伴侣，一起共享清单和提醒。';

  @override
  String get householdShareLink => '分享链接';

  @override
  String get householdShowQr => '显示二维码';

  @override
  String get householdConnectToFamily => '加入家庭';

  @override
  String get householdInviteDescriptionWhenConnecting =>
      '我们检测到了邀请码，如果识别有误，你也可以手动输入';

  @override
  String get householdGotInvited => '你已被邀请加入一个家庭';

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
  String get notificationsAddToListPill => '＋ 加入清单';

  @override
  String get userCreateProfileTitle => '你叫什么名字？';

  @override
  String get userCreateProfileSubtitle => '添加名字和照片，你的伴侣会在共享清单中看到。';

  @override
  String get userCreateProfileNameHint => '你的名字';

  @override
  String get userCreateProfileSkip => '跳过';

  @override
  String get userCreateProfileNext => '下一步';

  @override
  String get searchHint => '商品或食谱…';

  @override
  String get searchNothingFound => '未找到内容';

  @override
  String get insightsTitle => '洞察';

  @override
  String get recipeImportTitle => '从链接导入食谱';

  @override
  String get recipeIngredients => '食材';

  @override
  String recipeAddToListCta(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '添加 $countString 个商品到清单';
  }

  @override
  String get recipeParseButton => '解析';

  @override
  String get navList => '清单';

  @override
  String get navPora => 'Pora';

  @override
  String get navProfile => '个人资料';

  @override
  String get familiesTitle => '家庭';

  @override
  String get familiesSubtitle => '选择一个家庭以打开它的清单';

  @override
  String get familiesCreateDialog => '给家庭起个什么名字？';

  @override
  String get tryToUpdate => '尝试刷新';

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
  String get welcomeBackSubtitle => '稍等，正在打开你的清单…';

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
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get notificationsPermission => '通知权限';

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
  String get deleteItemTitle => '删除此商品？';

  @override
  String get deleteItemBody => '此操作无法撤销。';

  @override
  String get dontAskAgain => '不再询问';

  @override
  String get delete => '删除';

  @override
  String get returnToList => '返回清单';

  @override
  String get nooneToNotify => '没有可通知的人';

  @override
  String get notFound => '未找到';

  @override
  String get recipeEmptyHint => '粘贴食谱链接并点击“解析”';

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
  String get deleteListTitle => '删除清单？';

  @override
  String deleteListBody(String listName) {
    return '清单“$listName”及其中的所有商品都将被删除。此操作无法撤销。';
  }

  @override
  String get membersScreenTitle => '成员';

  @override
  String get owner => '所有者';

  @override
  String get member => '成员';

  @override
  String get addProduct => '添加商品';

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
    return '添加者：$name';
  }

  @override
  String get splashLoadingSlow => '快完成了…';

  @override
  String get splashLoadingVerySlow => '仍在加载…正在检查连接';

  @override
  String get profileNameUpdate => '正在更新资料';

  @override
  String get briefSnackBar => '是不是忘了选择商品？';

  @override
  String get noInternet => '无网络连接';

  @override
  String get noInternetButLoadYouLocally => '无网络连接，将为你加载本地数据';

  @override
  String get groupDeletionTitle => '确定要删除该群组吗？';

  @override
  String get retry => '重试';

  @override
  String get groupsTitle => '你的群组';

  @override
  String get groupsSubtitle => '一个清单就是一个群组。邀请他人后，他们就能看到这个清单。';

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
  String get tutorialTitle => '使用方法';

  @override
  String get tutorialSkip => '跳过';

  @override
  String get tutorialNext => '下一步';

  @override
  String get tutorialDone => '开始';

  @override
  String get tutorialInviteTitle => '邀请你的家人';

  @override
  String get tutorialInviteBody => '将群组向右滑动 → 邀请。你的伴侣会看到同一份清单。';

  @override
  String get tutorialAddTitle => '添加商品';

  @override
  String get tutorialAddBody => '点击清单底部的 +，填写名称、数量、分类、优先级，就完成了。';

  @override
  String get tutorialEditTitle => '编辑与勾选';

  @override
  String get tutorialEditBody => '点击复选框表示已购买；点击该行可查看详情和编辑。';

  @override
  String get tutorialDeleteTitle => '删除';

  @override
  String get tutorialDeleteBody => '将商品向左滑动 → 删除。删除确认可以关闭。';

  @override
  String get tutorialAiTitle => '导入食谱';

  @override
  String get tutorialAiBody => '粘贴食谱链接，点击“解析”。食材会加入清单，重复项会被标记。';

  @override
  String get tutorialSettingsTitle => '一切触手可及';

  @override
  String get tutorialSettingsBody => '主题、语言、通知、确认，都在 个人资料 → 高级设置 中。';

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
  String get tutorialSampleIngredient1 => '意大利面 400 克';

  @override
  String get tutorialSampleIngredient2 => '番茄 500 克';

  @override
  String get tutorialSampleIngredient3 => '大蒜 3 瓣';

  @override
  String get tutorialSampleToggleTheme => '主题';

  @override
  String get tutorialSampleToggleNotif => '通知';

  @override
  String get tutorialSampleToggleConfirm => '确认';

  @override
  String get tutorialConnectTitle => '通过邀请码加入';

  @override
  String get tutorialConnectBody => '伴侣发来链接或邀请码，粘贴后你就加入共享清单了。';

  @override
  String get tutorialNotifyTitle => '提醒「现在需要」';

  @override
  String get tutorialNotifyBody => '在商品上点击「!」，你的伴侣会收到「马上买」的推送，不用再打电话。';

  @override
  String get tutorialOutroTitle => '剩下的你自己就能搞定';

  @override
  String get tutorialOutroBody => '随便点、随便滑，弄错也没关系，应用几乎都能包容。';

  @override
  String get tutorialSampleInviteCode => 'PORA-4F72';

  @override
  String get tutorialSamplePushSender => '安娜';

  @override
  String get tutorialSamplePushBody => '急需牛奶';

  @override
  String get tutorialSampleInviteMessage => '加入清单吧';

  @override
  String get supportMessage => '联系客服';

  @override
  String get supportMessageBottomSheetTopDescription =>
      '你的消息将发送给客服团队。请尽可能详细地描述问题。';

  @override
  String get supportMessageBottomSheetSendButton => '发送';

  @override
  String get supportMessageBottomSheetUnderButtonText => '我们会尽快通过邮件或应用内消息回复你！';

  @override
  String get allergen => '过敏原';

  @override
  String get predictionsGreeting => '你与 PORA 的一天';

  @override
  String get predictionsGreetingSub => '根据你的购买记录生成的智能提示';

  @override
  String get predictionsSectionSoon => '即将用完';

  @override
  String get predictionsSectionAiSuggests => 'AI 推荐';

  @override
  String get refresh => '刷新';

  @override
  String get kpiWeek => '商品';

  @override
  String get kpiRecipes => '常买';

  @override
  String get kpiDaysToRun => '快用完';

  @override
  String get fallbackTip1 => '像插花一样保存香草：插进一杯水里，再用袋子罩住，可保鲜 2 周。';

  @override
  String get fallbackTip2 => '最后再往面团里加盐，因为盐会抑制酵母。';

  @override
  String get fallbackTip3 => '切洋葱前先放进冷冻室冰 15 分钟，就不会辣眼睛了。';

  @override
  String get fallbackTip4 => '汤太咸了？放一个生土豆煮 10 分钟，能吸走多余的盐分。';

  @override
  String get fallbackTip5 => '把鸡蛋放进水里检验新鲜度：下沉的新鲜，浮起的就扔掉。';

  @override
  String get fallbackTip6 => '用加盖的平底锅加热披萨，饼皮会重新变脆。';

  @override
  String get fallbackTip7 => '冷冻过的肉更容易切薄：切之前放冷冻室 20 分钟。';

  @override
  String get fallbackTip8 => '切柠檬前先在台面上滚一滚，能挤出更多汁。';

  @override
  String get fallbackTip9 => '番茄酱汁里加一小撮糖，可以中和酸味。';

  @override
  String get fallbackTip10 => '面包放冷冻室可以保存一个月，烤的时候无需解冻，直接烤即可。';

  @override
  String get aiTipOfDayLabel => '每日小贴士';

  @override
  String get aiTipOfDayTopic => '今天';

  @override
  String get aiCtaTitle => '询问 PORA';

  @override
  String get aiCtaSubtitle => '食谱 · 食材替代 · 小贴士';

  @override
  String get chatSheetTitle => 'PORA';

  @override
  String get chatSheetSubtitle => '询问食物、采购和替代方案';

  @override
  String get chatEmptyTitle => '开始对话';

  @override
  String get chatEmptyExamplesLabel => '示例问题：';

  @override
  String get chatSample1 => '鸡肉和米饭能做什么菜？';

  @override
  String get chatSample2 => '面团里的酸奶油可以用什么代替？';

  @override
  String get chatSample3 => '香草怎么保存才不会蔫？';

  @override
  String get chatSample4 => '20 分钟快手晚餐食谱';

  @override
  String get chatSample5 => '怎样在蔬菜变质前把它们用完？';

  @override
  String get chatSample6 => '帮我列一份 3 种简单早餐的购物清单';

  @override
  String get chatSample7 => '预算不多，两个人做什么吃好？';

  @override
  String get chatSample8 => '熟米饭在冰箱里能放多久？';

  @override
  String get chatSample9 => '推荐一份高蛋白的素食晚餐';

  @override
  String get chatSample10 => '这道菜里的黄油可以用什么代替？';

  @override
  String get chatSample11 => '用我现有的食材安排三顿晚餐';

  @override
  String get chatSample12 => '剩菜 15 分钟内能做什么？';

  @override
  String get chatSample13 => '根据我的清单推荐一道不含过敏原的菜';

  @override
  String get chatSample14 => '怎样让这顿饭更省钱？';

  @override
  String get chatTyping => 'PORA 正在输入…';

  @override
  String get chatInputHint => '随便问…';

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
  String get tipTopicsSectionTitle => '小贴士主题';

  @override
  String get tipTopicsSectionDescription => '选择小贴士的主题范围';

  @override
  String get tipTopicsAddCustom => '添加自定义主题';

  @override
  String get tipTopicsCustomLabel => '自定义';

  @override
  String get tipTopicsPredefinedLabel => '预设';

  @override
  String get tipTopicsEmpty => '未选择主题，将显示通用小贴士';

  @override
  String get insightsChampionKicker => '你的最爱';

  @override
  String insightsChampionSubtitle(int count) {
    return '已购买 $count 次';
  }

  @override
  String insightsStreakDays(int days) {
    return '连续 $days 天';
  }

  @override
  String get insightsStreakSubtitle => '状态正佳，继续保持';

  @override
  String insightsFreqEvery(int days) {
    return '~每 $days 天';
  }

  @override
  String get insightsPopular => '你经常购买';

  @override
  String get insightsStatsProducts => '件商品';

  @override
  String get insightsEmpty => '暂无数据，先添加一些商品吧';

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
  String get notificationsEmptyBody => '新通知会显示在这里';

  @override
  String get recipeCreateListCta => '要把这个食谱添加到哪里？';

  @override
  String get offlineWriteBlocked => '无网络，此更改不会保存';

  @override
  String get offlineSavedQueued => '已保存。联网后将自动发送';

  @override
  String offlineSyncDropped(int count) {
    return '$count 项更改同步失败';
  }

  @override
  String get offlineReadBanner => '离线 — 正在显示缓存数据';

  @override
  String get chatImportRecipeCta => '导入食谱';

  @override
  String get listsEmptyTitle => '你还没有任何清单';

  @override
  String get listsEmptySubtitle => '要不要创建一个新的？';

  @override
  String get aiModelSettingsSection => 'Pora-AI 模型';

  @override
  String get aiConfigRow => '自定义 Pora-AI 模型';

  @override
  String get aiConfigRowSubtitle => '使用你自己的 OpenRouter 密钥和模型';

  @override
  String get aiConfigTitle => 'Pora-AI 模型';

  @override
  String get aiConfigIntro =>
      '连接你自己的 OpenRouter API 密钥并选择 Pora-AI 使用的模型。留空则使用应用默认值。';

  @override
  String get aiConfigApiKeyLabel => 'OpenRouter API 密钥';

  @override
  String get aiConfigApiKeyHint => 'sk-or-...';

  @override
  String get aiConfigModelsSection => '模型';

  @override
  String get aiConfigPoraModelLabel => 'PORA-AI 模型';

  @override
  String get aiConfigPoraModelHint => '例如 openai/gpt-4o-mini';

  @override
  String get aiConfigTipsModelLabel => '小贴士 (Tips) 模型';

  @override
  String get aiConfigTipsModelHint => '留空 — 与应用默认相同';

  @override
  String get aiConfigNeedKeyNote => '输入 API 密钥后才能选择自定义模型';

  @override
  String get aiConfigReset => '恢复默认';

  @override
  String get aiConfigSaved => '已保存 Pora-AI 设置';

  @override
  String get aiConfigResetDone => '已恢复 Pora-AI 默认设置';

  @override
  String get aiConfigInfoTitle => '如何连接你的模型';

  @override
  String get aiConfigInfoBody =>
      '1. 在 openrouter.ai 注册一个免费账户。\n2. 打开 Keys，创建一个新的 API 密钥并粘贴到这里。\n3. 在 openrouter.ai/models 复制一个模型 ID（例如 openai/gpt-4o-mini 或 anthropic/claude-3.5-sonnet）。\n4. 将 ID 粘贴到 PORA-AI 字段。Tips 字段可选——留空即可用你的密钥调用应用默认模型。\n\n你的密钥仅存储在本设备上，且仅用于你的 Pora-AI 请求。';

  @override
  String get aiConfigInfoClose => '知道了';

  @override
  String get supportEmptyError => '请先填写消息内容';

  @override
  String get supportSent => '消息已发送——我们会尽快回复';

  @override
  String get supportFailed => '发送失败。请检查网络后重试';

  @override
  String get supportSheetHint => '描述你的问题或反馈……';

  @override
  String get shortcutAddItem => '添加商品';

  @override
  String importantReminderTitle(String product) {
    return '购买 $product';
  }

  @override
  String importantReminderFrom(String user) {
    return '来自 $user';
  }

  @override
  String get importantReminderBody => '买到后请标记「已购买」';

  @override
  String get importantReminderMarkBought => '已购买';

  @override
  String get liveActivityTestRow => '测试 Live Activity';

  @override
  String get liveActivityTestSample => '牛奶';

  @override
  String get listPickerTitle => '添加到哪个清单？';

  @override
  String get listPickerEmpty => '还没有清单——请先创建一个';

  @override
  String get predictionsAdded => '已加入清单';

  @override
  String get shortcutOpenLists => '打开清单';

  @override
  String get shortcutOpenPora => '问 Pora-AI';

  @override
  String insightsPeriodDays(int days) {
    return '$days天';
  }

  @override
  String insightsStreakBest(int days) {
    return '最长纪录：$days';
  }

  @override
  String get insightsStreakStart => '每天打开 Pora，开启连续记录';

  @override
  String get insightsKpiAdded => '已添加';

  @override
  String get insightsKpiBought => '已购买';

  @override
  String get insightsKpiCompletion => '添加后已购买';

  @override
  String get insightsKpiActiveDays => '活跃天数';

  @override
  String get insightsKpiMinutes => '使用分钟数';

  @override
  String get insightsKpiSessions => '次会话';

  @override
  String insightsAvgSession(String minutes) {
    return '每次约 $minutes 分钟';
  }

  @override
  String get insightsActivityTitle => '添加与购买';

  @override
  String get insightsActivityEmpty => '该时段暂无活动';

  @override
  String get insightsHeatmapTitle => '近 4 周活跃度';

  @override
  String get insightsLess => '少';

  @override
  String get insightsMore => '多';

  @override
  String get insightsRhythmTitle => '你的节奏';

  @override
  String get insightsPartMorning => '早上';

  @override
  String get insightsPartAfternoon => '下午';

  @override
  String get insightsPartEvening => '晚上';

  @override
  String get insightsPartNight => '夜间';

  @override
  String get insightsPeakMorning => '你在早上最活跃';

  @override
  String get insightsPeakAfternoon => '你在下午最活跃';

  @override
  String get insightsPeakEvening => '你在晚上最活跃';

  @override
  String get insightsPeakNight => '你在夜间最活跃';

  @override
  String insightsPeakWeekday(String day) {
    return '最活跃的一天：$day';
  }

  @override
  String get insightsCategoriesTitle => '你常添加的类别';

  @override
  String get insightsDueSoonTitle => '该补货了';

  @override
  String get insightsDueNow => '现在';

  @override
  String insightsDueInDays(int days) {
    return '约 $days 天后';
  }

  @override
  String get insightsTopBoughtTitle => '本时段购买最多';

  @override
  String get insightsEngagementTitle => '你如何使用 Pora';

  @override
  String get insightsKpiListsOpened => '打开清单';

  @override
  String get insightsKpiListsCreated => '新建清单';

  @override
  String get insightsKpiRecipes => '导入食谱';

  @override
  String get insightsKpiAi => '发给 Pora 的消息';

  @override
  String get insightsKpiDeleted => '已删除';

  @override
  String get insightsAllTimeTitle => '累计';

  @override
  String get insightsKpiReminders => '设有提醒';

  @override
  String get insightsKpiUrgent => '紧急';

  @override
  String get insightsLocalNote => '此页面的使用统计在你的设备上计算';

  @override
  String get insightsNoUsageYet => '使用 Pora 后将显示统计';

  @override
  String get settingsDeleteAccount => '删除账户';

  @override
  String get deleteAccountTitle => '删除账户？';

  @override
  String get deleteAccountBody =>
      '你的个人资料、个人清单和使用数据将被永久删除。共享的家庭清单会保留在家庭中；如果你是家庭所有者，所有权将转给加入最早的成员。此操作无法撤销。';

  @override
  String get deleteAccountFailed => '无法删除账户。请检查网络连接后重试。';

  @override
  String get chatReportAi => '举报';

  @override
  String get chatReportSent => '谢谢，我们会审核这条回答。';

  @override
  String get chatReportFailed => '举报发送失败，请稍后重试。';

  @override
  String get aiDisclaimer => 'Pora AI 可能会出错，请核实重要信息。';

  @override
  String get groupLeave => '退出';

  @override
  String get groupLeaveTitle => '退出此群组？清单将保留给其他成员。';

  @override
  String get groupDeleteOwnerOnly => '只有群组所有者可以删除它';

  @override
  String get groupDeleteFailed => '无法删除群组，请重试。';

  @override
  String get groupLeaveFailed => '无法退出群组，请重试。';
}
