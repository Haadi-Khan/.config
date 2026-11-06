import QtQuick

// Direct wheel/touchpad scrolling for a ListView/Flickable. Qt's default
// wheel handling barely moves on this touchpad (its pixelDelta is only ~8px
// per event), so scroll by angleDelta instead.
// Declare inside the list:  WheelScroll { flickable: myList }
WheelHandler {
    required property Flickable flickable
    // Pixels per angle unit: a mouse notch (120) moves 60px; a touchpad
    // swipe (~15 events of ~100) moves ~700px.
    property real speed: 0.5

    target: null
    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

    onWheel: e => {
        const f = flickable;
        const dy = e.angleDelta.y * speed;
        const top = f.originY;
        const bottom = f.originY + Math.max(0, f.contentHeight - f.height);
        f.contentY = Math.max(top, Math.min(bottom, f.contentY - dy));
    }
}
