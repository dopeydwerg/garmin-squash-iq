/*
using Toybox.Application as App;
using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Math as Mt;
using Toybox.System as Sys;

class PlayerPicker extends WatchUi.Picker {
    hidden var mFactory;
    function initialize() {
        mFactory = new PlayerPickerFactory();

        mTitle = new WatchUi.Text({:text=>Rez.Strings.player_picker_title, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, :color=>Graphics.COLOR_WHITE});

        Picker.initialize({:title=>mTitle, :pattern=>[mFactory]});
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
    }
}

class PlayerPickerDelegate extends WatchUi.PickerDelegate {
    hidden var mManageScore;
    function initialize(manageScore) {
        PickerDelegate.initialize();
        mManageScore = manageScore;
    }

    function onCancel() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    function onAccept(values) {
    Toybox.System.println(values[0]);
    Toybox.System.println(WatchUi.loadResource(Rez.Strings.player_picker_item_you));
        if (values[0] == Rez.Strings.player_picker_item_you) {
            Toybox.System.println("Player one should be chosen here");
            mManageScore.invoke(:player_1);
        } else if (values[0] == Rez.Strings.player_picker_item_random) {
            Toybox.System.println("Random player should be chosen here");
            var r;
            r = (Mt.rand() % 900 + 100) % 2; //Random number between 100 and 1000 (900+100)
            mManageScore.invoke(r == 0 ? :player_1 : :player_2);
        } else {
            mManageScore.invoke(:player_2);
        }
        Toybox.System.println("something happened");
        Toybox.System.println(values[0]);
    }
}

class PlayerPickerFactory extends WatchUi.PickerFactory {
    var mPlayerNames;

    function initialize() {
        PickerFactory.initialize();
        mPlayerNames = [Rez.Strings.player_picker_item_you, App.getApp().getProperty("opponent_name"), Rez.Strings.player_picker_item_random];
    }

    function getIndex(value) {
        for (var i = 0; i < mPlayerNames.size(); i++) {
            if (value == mPlayerNames[i]) {
                return i;
            }
        }
        return null;
    }

    function getSize() {
        return mPlayerNames.size();
    }

    function getValue(index) {
        return mPlayerNames[index];
    }

    function getDrawable(index, isSelected) {
        return new WatchUi.Text( { :text=>getValue(index), :color=>Graphics.COLOR_WHITE, :font=> Graphics.FONT_LARGE, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER } );
    }
}
*/