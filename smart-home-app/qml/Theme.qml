pragma Singleton
import QtQuick

QtObject {
    // Color Palette - Dark Theme
    readonly property color backgroundPrimary: "#0f1419"
    readonly property color backgroundSecondary: "#1a232e"
    readonly property color backgroundCard: "#243447"
    readonly property color backgroundCardHover: "#2d4158"
    
    readonly property color accentPrimary: "#00bcd4"
    readonly property color accentSecondary: "#26c6da"
    readonly property color accentGlow: "#00bcd440"
    
    readonly property color successColor: "#4caf50"
    readonly property color errorColor: "#f44336"
    readonly property color warningColor: "#ff9800"
    
    readonly property color textPrimary: "#ffffff"
    readonly property color textSecondary: "#b0bec5"
    readonly property color textDisabled: "#546e7a"
    
    readonly property color borderColor: "#37474f"
    readonly property color dividerColor: "#263238"
    
    // Typography
    readonly property string fontFamily: "Roboto, Arial, sans-serif"
    readonly property real fontSizeSmall: 12
    readonly property real fontSizeNormal: 14
    readonly property real fontSizeMedium: 16
    readonly property real fontSizeLarge: 20
    readonly property real fontSizeXLarge: 24
    readonly property real fontSizeTitle: 32
    
    // Spacing
    readonly property real spacingXS: 4
    readonly property real spacingS: 8
    readonly property real spacingM: 16
    readonly property real spacingL: 24
    readonly property real spacingXL: 32
    
    // Touch targets (minimum 48dp for accessibility)
    readonly property real touchTargetMin: 48
    readonly property real touchTargetComfortable: 56
    
    // Card dimensions
    readonly property real cardCornerRadius: 12
    readonly property real cardElevation: 4
    readonly property real cardMinWidth: 140
    readonly property real cardMinHeight: 100
    
    // Animation durations
    readonly property int animationFast: 150
    readonly property int animationNormal: 250
    readonly property int animationSlow: 350
    
    // Glassmorphism effect
    readonly property color glassBackground: "#24344780"
    readonly property real glassBlur: 20
    readonly property real glassBorderWidth: 1
    readonly property color glassBorderColor: "#ffffff20"
}
