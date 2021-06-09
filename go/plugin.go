package systray

import (
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"

	"github.com/go-flutter-desktop/go-flutter"
	"github.com/go-flutter-desktop/go-flutter/plugin"
	"github.com/go-gl/glfw/v3.3/glfw"
)

const channelName = "plugins.sonr.io/systray"

// SystrayPlugin implements flutter.Plugin and handles method.
type SystrayPlugin struct {
	window  *glfw.Window
	channel *plugin.MethodChannel
}

type MainEntry struct {
	Title    string
	IconPath string
}

type ActionEnumType string

type actionType struct {
	Quit         ActionEnumType
	Focus        ActionEnumType
	SystrayEvent ActionEnumType
}

var ActionType = &actionType{
	Quit:         "0",
	Focus:        "1",
	SystrayEvent: "2",
}

type SystrayAction struct {
	Name       string
	Label      string
	ActionType ActionEnumType
}

var _ flutter.Plugin = &SystrayPlugin{} // compile-time type check

// InitPluginGLFW initializes the GLFW
func (p *SystrayPlugin) InitPluginGLFW(window *glfw.Window) error {
	p.window = window
	return nil
}

// InitPlugin initializes the plugin.
func (p *SystrayPlugin) InitPlugin(messenger plugin.BinaryMessenger) error {
	p.channel = plugin.NewMethodChannel(messenger, channelName, plugin.StandardMethodCodec{})
	p.channel.HandleFuncSync("initSystray", p.initSystrayHandler)
	p.channel.HandleFunc("updateMenu", p.updateMenuHandler)
	return nil
}

func (p *SystrayPlugin) initSystrayHandler(arguments interface{}) (reply interface{}, err error) {
	// Convert the params into SystrayAction type list
	var mainEntry MainEntry
	err = json.Unmarshal([]byte(arguments.(string)), &mainEntry)
	if err != nil {
		fmt.Println("Failed to parse arguments: ", err)
		return nil, errors.New("failed to parse json")
	}

	var iconData []byte
	var title string

	if len(mainEntry.IconPath) > 0 {
		var data []byte
		data, err := parseIcon(mainEntry.IconPath)
		if err != nil {
			fmt.Println(fmt.Sprintf("An error has occurred while parsing the icon: %s", err))
		}

		if data != nil {
			iconData = data
		}
	}

	if len(mainEntry.Title) > 0 {
		title = mainEntry.Title
	}

	initialize(title, iconData)

	return "ok", nil
}

func (p *SystrayPlugin) updateMenuHandler(arguments interface{}) (reply interface{}, err error) {
	var actions []SystrayAction
	err = json.Unmarshal([]byte(arguments.(string)), &actions)
	if err != nil {
		fmt.Println("Failed to get config json file: ", err)
		return nil, errors.New("failed to parse json")
	}

	p.updateMenu(actions)

	return "ok", nil
}

func (p *SystrayPlugin) focusHandler(action *SystrayAction) func() {
	return func() {
		p.window.Show()
	}
}

func (p *SystrayPlugin) closeHandler(action *SystrayAction) func() {
	return func() {
		p.window.SetShouldClose(true)
	}
}

func (p *SystrayPlugin) eventHandler(action *SystrayAction) func() {
	return func() {
		err := p.invokeSystrayEvent(action)
		if err != nil {
			fmt.Println(fmt.Sprintf("An error has occurred while invoking SystrayEvent: %s", err))
		}
	}
}

func (p *SystrayPlugin) invokeSystrayEvent(action *SystrayAction) error {
	err := p.channel.InvokeMethod("systrayEvent", action.Name)
	if err != nil {
		return err
	}

	return nil
}

func parseIcon(absPath string) ([]byte, error) {
	// Parse the icon if available
	var data []byte
	if len(absPath) > 0 {
		data, err := ioutil.ReadFile(absPath)
		if err != nil {
			return nil, errors.New(fmt.Sprintf("file reading error: %s", err))
		}
		return data, nil
	}
	return data, nil
}
