package main

// DO NOT EDIT, this file is generated by hover at compile-time for the flutter_systray plugin.

import (
	flutter "github.com/go-flutter-desktop/go-flutter"
	systray "github.com/jackstefansky/systray/go"
)

func init() {
	// Only the init function can be tweaked by plugin maker.
	options = append(options, flutter.AddPlugin(&systray.SystrayPlugin{}))
}
