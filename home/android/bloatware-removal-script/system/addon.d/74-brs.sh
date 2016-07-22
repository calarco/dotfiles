#!/sbin/sh
# 
# /system/addon.d/74-brs.sh
#
. /tmp/backuptool.functions

list_files() {
cat <<EOF

EOF
}

case "$1" in
  backup)
    list_files | while read FILE DUMMY; do
      backup_file $S/$FILE
    done
  ;;
  restore)
    list_files | while read FILE REPLACEMENT; do
      R=""
      [ -n "$REPLACEMENT" ] && R="$S/$REPLACEMENT"
      [ -f "$C/$S/$FILE" ] && restore_file $S/$FILE $R
    done
  ;;
  pre-backup)
    # Stub
  ;;
  post-backup)
    # Stub
  ;;
  pre-restore)
    # Stub
  ;;
  post-restore)
   rm -rf /system/app/Apollo
   rm -f /system/app/Apollo/Apollo.apk
   rm -rf /system/app/BasicDreams
   rm -f /system/app/BasicDreams/BasicDreams.apk
   rm -rf /system/app/Browser
   rm -f /system/app/Browser/Browser.apk
   rm -rf /system/app/BrowserProviderProxy
   rm -f /system/app/BrowserProviderProxy/BrowserProviderProxy.apk
   rm -rf /system/app/Calendar
   rm -f /system/app/Calendar/Calendar.apk
   rm -rf /system/app/Camera2
   rm -f /system/app/Camera2/Camera2.apk
   rm -rf /system/app/CameraNext
   rm -f /system/app/Camera2/CameraNext.apk
   rm -rf /system/app/CellBroadcastReceiver
   rm -f /system/app/CellBroadcastReceiver/CellBroadcastReceiver.apk
   rm -rf /system/app/CMHome
   rm -f /system/app/CMHome/CMHome.apk
   rm -rf /system/app/CMWallpapers
   rm -f /system/app/CMWallpapers/CMWallpapers.apk
   rm -rf /system/app/DashClock
   rm -f /system/app/DashClock/DashClock.apk
   rm -rf /system/app/DSPManager
   rm -f /system/app/DSPManager/DSPManager.apk
   rm -rf /system/app/Eleven
   rm -f /system/app/Eleven/Eleven.apk
   rm -rf /system/app/Email
   rm -f /system/app/Email/Email.apk
   rm -rf /system/app/Exchange2
   rm -f /system/app/Exchange2/Exchange2.apk
   rm -rf /system/app/Galaxy4
   rm -f /system/app/Galaxy4/Galaxy4.apk
   rm -rf /system/app/Gallery2
   rm -f /system/app/Gallery2/Gallery2.apk
   rm -rf /system/app/Gello
   rm -f /system/app/Gello/Gello.apk
   rm -rf /system/app/DeskClock
   rm -f /system/app/DeskClock/DeskClock.apk
   rm -rf /system/app/HoloSpiralWallpaper
   rm -f /system/app/HoloSpiralWallpaper/HoloSpiralWallpaper.apk
   rm -rf /system/app/LiveWallpapers
   rm -f /system/app/LiveWallpapers/LiveWallpapers.apk
   rm -rf /system/app/MagicSmokeWallpapers
   rm -f /system/app/MagicSmokeWallpapers/MagicSmokeWallpapers.apk
   rm -rf /system/app/messaging
   rm -f /system/app/messaging/messaging.apk
   rm -rf /system/app/Music
   rm -f /system/app/Music/Music.apk
   rm -rf /system/app/NoiseField
   rm -f /system/app/NoiseField/NoiseField.apk
   rm -rf /system/app/PartnerBookmarksProvider
   rm -f /system/app/PartnerBookmarksProvider/PartnerBookmarksProvider.apk
   rm -rf /system/app/PhaseBeam
   rm -f /system/app/PhaseBeam/PhaseBeam.apk
   rm -rf /system/app/PhotoPhase
   rm -f /system/app/PhotoPhase/PhotoPhase.apk
   rm -rf /system/app/PhotoTable
   rm -f /system/app/PhotoTable/PhotoTable.apk
   rm -rf /system/app/Provision
   rm -f /system/app/Provision/Provision.apk
   rm -rf /system/app/QuickSearchBox
   rm -f /system/app/QuickSearchBox/QuickSearchBox.apk
   rm -rf /system/app/Snap
   rm -f /system/app/Snap/Snap.apk
   rm -rf /system/app/Vending
   rm -f /system/app/Vending/Vending.apk
   rm -rf /system/app/VideoEditor
   rm -f /system/app/VideoEditor/VideoEditor.apk
   rm -rf /system/app/VisualizationWallpapers
   rm -f /system/app/VisualizationWallpapers/VisualizationWallpapers.apk
   rm -rf /system/app/VoicePlus
   rm -f /system/app/VoicePlus/VoicePlus.apk
   rm -rf /system/app/WhisperPush
   rm -f /system/app/WhisperPush/WhisperPush.apk
   rm -rf /system/priv-app/AudioFX
   rm -f /system/priv-app/AudioFX/AudioFX.apk
   rm -rf /system/priv-app/BrowserProviderProxy
   rm -f /system/priv-app/BrowserProviderProxy/BrowserProviderProxy.apk
   rm -rf /system/priv-app/Contacts
   rm -f /system/priv-app/Contacts/Contacts.apk
#   rm -rf /system/priv-app/Dialer
#   rm -f /system/priv-app/Dialer/Dialer.apk
   rm -rf /system/priv-app/PartnerBookmarksProvider
   rm -f /system/priv-app/PartnerBookmarksProvider/PartnerBookmarksProvider.apk
   rm -rf /system/priv-app/PicoTts
   rm -f /system/priv-app/PicoTts/PicoTts.apk
   rm -rf /system/priv-app/Provision
   rm -f /system/priv-app/Provision/Provision.apk
   rm -rf /system/priv-app/QuickSearchBox
   rm -f /system/priv-app/QuickSearchBox/QuickSearchBox.apk
   rm -rf /system/priv-app/talkback
   rm -f /system/priv-app/talkback/talkback.apk
   rm -rf /system/priv-app/Vending
   rm -f /system/priv-app/Vending/Vending.apk
  ;;
esac
