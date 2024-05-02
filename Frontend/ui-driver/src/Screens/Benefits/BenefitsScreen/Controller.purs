module Screens.Benefits.BenefitsScreen.Controller where

import JBridge (shareTextMessage, minimizeApp, firebaseLogEvent, hideKeyboardOnNavigation, cleverTapCustomEvent, metaLogEvent, shareImageMessage, setCleverTapUserProp)
import Log (trackAppActionClick, trackAppBackPress, trackAppScreenRender)
import Prelude (class Show, bind, pure, ($))
import PrestoDOM (Eval, update, continue, exit)
import PrestoDOM.Types.Core (class Loggable)
import Screens (getScreen, ScreenName(..))
import Screens.Types 
import Effect.Unsafe (unsafePerformEffect)
import Engineering.Helpers.LogEvent (logEvent, logEventWithMultipleParams)
import Components.GenericHeader as GenericHeader
import PrestoDOM (Eval, update, continue, exit, continueWithCmd, updateAndExit)
import Prelude (bind, class Show, pure, unit, ($), discard, (>=), (<=), (==), (&&), not, (+), show, void, (<>), when, map, negate, (-), (>), (/=), (<))
import Log (trackAppActionClick, trackAppEndScreen, trackAppScreenRender, trackAppBackPress, trackAppTextInput, trackAppScreenEvent)
import Language.Strings (getString)
import Language.Types (STR(..))
import Components.BottomNavBar as BottomNavBar
import Storage (KeyStore(..), getValueToLocalNativeStore, setValueToLocalNativeStore, getValueToLocalStore)
import Helpers.Utils (incrementValueOfLocalStoreKey, generateReferralLink, generateQR)
import Components.PrimaryButton as PrimaryButton
import Common.Types.App (ShareImageConfig)
import Engineering.Helpers.Commons (getNewIDWithTag)
import Data.Maybe (Maybe(..), fromMaybe, isJust)
import MerchantConfig.Utils (getMerchant, Merchant(..))
import Common.Types.App (LazyCheck(..))
import Foreign (unsafeToForeign)
import Data.Array (find)
import Services.API
import Effect.Uncurried (runEffectFn4)
import Debug (spy)
import Screens.Benefits.BenefitsScreen.Transformer (buildLmsModuleRes)

instance showAction :: Show Action where
  show _ = ""
instance loggableAction :: Loggable Action where
  performLog action appId = case action of
    AfterRender -> trackAppScreenRender appId "screen" "BenefitsScreen"
    BackPressed -> trackAppBackPress appId (getScreen REFERRAL_SCREEN)
    GenericHeaderActionController act -> case act of
      GenericHeader.PrefixImgOnClick -> do
        trackAppActionClick appId (getScreen REFERRAL_SCREEN) "generic_header_action" "back_icon"
        trackAppEndScreen appId (getScreen REFERRAL_SCREEN)
      GenericHeader.SuffixImgOnClick -> trackAppActionClick appId (getScreen REFERRAL_SCREEN) "generic_header_action" "forward_icon"
    ShowQRCode -> pure unit
    BottomNavBarAction (BottomNavBar.OnNavigate item) -> do
      trackAppActionClick appId (getScreen REFERRAL_SCREEN) "bottom_nav_bar" "on_navigate"
      trackAppEndScreen appId (getScreen REFERRAL_SCREEN)
    LearnMore -> pure unit
    PrimaryButtonActionController state act -> case act of
      PrimaryButton.OnClick -> do
        trackAppActionClick appId (getScreen REFERRAL_SCREEN) "primary_button_action" "next_on_click"
        trackAppEndScreen appId (getScreen REFERRAL_SCREEN)
      PrimaryButton.NoAction -> trackAppActionClick appId (getScreen REFERRAL_SCREEN) "primary_button_action" "no_action"
    ReferredDriversAPIResponseAction val -> pure unit
    ChangeTab tab -> trackAppActionClick appId (getScreen REFERRAL_SCREEN) "change_tab" (show tab)
    ShowReferedInfo referralInfoPopType -> trackAppActionClick appId (getScreen REFERRAL_SCREEN) "change_tab" (show referralInfoPopType)
    GoToLeaderBoard -> trackAppActionClick appId (getScreen REFERRAL_SCREEN) "change_tab" "leaderboard"
    UpdateDriverPerformance _ -> trackAppActionClick appId (getScreen REFERRAL_SCREEN) "referral_screen_response_action" "referral_screen_response_action"
    UpdateLeaderBoard _ -> trackAppActionClick appId (getScreen REFERRAL_SCREEN) "referral_screen_leaderboard_rank_action_action" "referral_screen_leaderboard_rank_action_action"
    RenderQRCode -> trackAppActionClick appId (getScreen REFERRAL_SCREEN) "screen" "render_qr_code"
    OpenModule _->  trackAppActionClick appId (getScreen REFERRAL_SCREEN) "go_to_module" "go_to_lms_video_screen"
    UpdateModuleList _ ->  trackAppActionClick appId (getScreen REFERRAL_SCREEN) "update_module_list" "update_module_list"
    UpdateModuleListErrorOccurred -> trackAppActionClick appId (getScreen REFERRAL_SCREEN) "update_module_list_error_occurred" "update_module_list"
    ShareQRLink -> trackAppActionClick appId (getScreen REFERRAL_SCREEN) "screen" "render_qr_link"

data Action = BackPressed
            | AfterRender
            | GenericHeaderActionController GenericHeader.Action
            | ShowQRCode
            | ShareQRLink
            | BottomNavBarAction BottomNavBar.Action
            | LearnMore
            | PrimaryButtonActionController BenefitsScreenState PrimaryButton.Action
            | ReferredDriversAPIResponseAction Int
            | ChangeTab DriverReferralType
            | ShowReferedInfo ReferralInfoPopType
            | GoToLeaderBoard
            | UpdateDriverPerformance GetPerformanceRes
            | UpdateLeaderBoard LeaderBoardRes
            | RenderQRCode
            | OpenModule LmsModuleRes
            | UpdateModuleList LmsGetModuleRes
            | UpdateModuleListErrorOccurred

data ScreenOutput = GoToHomeScreen BenefitsScreenState
                  | GoToNotifications BenefitsScreenState
                  | SubscriptionScreen BenefitsScreenState
                  | GoToDriverContestScreen BenefitsScreenState
                  | EarningsScreen BenefitsScreenState
                  | GoBack
                  | GoToLmsVideoScreen BenefitsScreenState

eval :: Action -> BenefitsScreenState -> Eval Action ScreenOutput BenefitsScreenState

eval BackPressed state = 
  if state.props.showDriverReferralQRCode then 
    continue state{props{showDriverReferralQRCode = false}}
  else if state.props.referralInfoPopType /= NO_REFERRAL_POPUP then 
    continue state{props{referralInfoPopType = NO_REFERRAL_POPUP}}
  else exit $ GoToHomeScreen state

eval (GenericHeaderActionController (GenericHeader.PrefixImgOnClick)) state = exit $ GoBack

eval ShowQRCode state = do
  let _ = unsafePerformEffect $ logEvent state.data.logField "ny_driver_contest_app_qr_code_click"
  continue state {props {showDriverReferralQRCode = true}}

eval ShareQRLink state = do
  let _ = unsafePerformEffect $ logEvent state.data.logField "ny_driver_contest_share_referral_code_click"
  let title = getString $ SHARE_NAMMA_YATRI "SHARE_NAMMA_YATRI"
  let message = (getString SHARE_NAMMA_YATRI_MESSAGE) <> title <> " " <> (getString NOW) <> "! \n" <> (generateReferralLink (getValueToLocalStore DRIVER_LOCATION) "qrcode" "referral" "coins" state.data.referralCode state.props.driverReferralType) <> (getString BE_OPEN_CHOOSE_OPEN) 
  _ <- pure $ shareTextMessage title message
  continue state

eval LearnMore state = exit $ GoToDriverContestScreen state

eval (PrimaryButtonActionController primaryButtonState (PrimaryButton.OnClick) ) state = continue state {props {showDriverReferralQRCode = false}}

eval (BottomNavBarAction (BottomNavBar.OnNavigate item)) state = do
  pure $ hideKeyboardOnNavigation true
  case item of
    "Home" -> exit $ GoToHomeScreen state
    "Earnings" -> exit $ EarningsScreen state
    "Alert" -> do
      void $ pure $ setValueToLocalNativeStore ALERT_RECEIVED "false"
      let _ = unsafePerformEffect $ logEvent state.data.logField "ny_driver_alert_click"
      exit $ GoToNotifications state
    "Join" -> do
      let driverSubscribed = getValueToLocalNativeStore DRIVER_SUBSCRIBED == "true"
      void $ pure $ incrementValueOfLocalStoreKey TIMES_OPENED_NEW_SUBSCRIPTION
      void $ pure $ cleverTapCustomEvent if driverSubscribed then "ny_driver_myplan_option_clicked" else "ny_driver_plan_option_clicked"
      void $ pure $ metaLogEvent if driverSubscribed then "ny_driver_myplan_option_clicked" else "ny_driver_plan_option_clicked"
      let _ = unsafePerformEffect $ firebaseLogEvent if driverSubscribed then "ny_driver_myplan_option_clicked" else "ny_driver_plan_option_clicked"
      exit $ SubscriptionScreen state
    "Earnings" -> exit $ EarningsScreen state
    _ -> continue state

eval (UpdateDriverPerformance (GetPerformanceRes resp)) state = do 
  continue state {data {totalReferredDrivers = fromMaybe 0 resp.referrals.totalReferredDrivers, totalActivatedCustomers = resp.referrals.totalActivatedCustomers, totalReferredCustomers = resp.referrals.totalReferredCustomers}}

eval (UpdateLeaderBoard (LeaderBoardRes resp)) state = do
  let currentDriverRank = case find (\(DriversInfo driverInfo) -> driverInfo.isCurrentDriver && driverInfo.totalRides /= 0) resp.driverList of
        Just (DriversInfo currentDriver) -> Just currentDriver.rank
        _ -> Nothing
  continue state {data {totalEligibleDrivers = resp.totalEligibleDrivers, rank = currentDriverRank}}

eval (ChangeTab tab) state = do
  let _ = unsafePerformEffect $ logEventWithMultipleParams state.data.logField "ny_driver_referral_scn_changetab" $ [{key : "Tab", value : unsafeToForeign (show tab)}]
  continueWithCmd state {props {driverReferralType = tab}}
    [ do
      runEffectFn4 generateQR (generateReferralLink (getValueToLocalStore DRIVER_LOCATION) "qrcode" "referral" "coins" state.data.referralCode tab) (getNewIDWithTag "ReferralQRCode") 500 0
      pure $ RenderQRCode
    ]

eval (ShowReferedInfo referralInfoPopType) state = 
  continue state {props {referralInfoPopType = referralInfoPopType}}

eval GoToLeaderBoard state = do
  let _ = unsafePerformEffect $ logEvent state.data.logField "ny_driver_go_to_leaderboard"
  exit $ GoToDriverContestScreen state

eval (OpenModule selectedModule) state = updateAndExit state { props{selectedModule = Just selectedModule}} $ GoToLmsVideoScreen state { props{selectedModule = Just selectedModule}}

eval (UpdateModuleList modules) state = continue state {data {moduleList = buildLmsModuleRes modules}, props {showShimmer = false}}

eval UpdateModuleListErrorOccurred state = continue state {props {showShimmer = false}}

eval _ state = update state

shareImageMessageConfig :: BenefitsScreenState -> ShareImageConfig
shareImageMessageConfig state = {
  code : state.data.referralCode,
  viewId : getNewIDWithTag "BenefitsQRScreen",
  logoId : getNewIDWithTag "BenefitsScreenLogo",
  isReferral : true
  }