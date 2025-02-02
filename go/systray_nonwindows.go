// +build linux darwin !windows

package systray

import "github.com/jackstefansky/trayhost"

func (p *SystrayPlugin) actionsToMenu(actions []SystrayAction) ([]trayhost.MenuItem, error) {
	var items []trayhost.MenuItem

	for _, action := range actions {
		localAction := action
		if localAction.ActionType == ActionType.Focus {
			// Adds a GLFW `window.Show` (https://godoc.org/github.com/go-gl/glfw/v3.2/glfw#Window.Show) operation to the
			// systray menu. It is used to bring window to front.
			mShow := trayhost.MenuItem{
				Title:   localAction.Label,
				Enabled: nil,
				Handler: p.focusHandler(&localAction),
			}
			items = append(items, mShow)
		} else if localAction.ActionType == ActionType.Quit {
			// Set up a handler to close the window
			mQuit := trayhost.MenuItem{
				Title:   localAction.Label,
				Enabled: nil,
				Handler: p.closeHandler(&localAction),
			}
			items = append(items, mQuit)
		} else if localAction.ActionType == ActionType.SystrayEvent {
			mEvent := trayhost.MenuItem{
				Title:   localAction.Label,
				Enabled: nil,
				Handler: p.eventHandler(&localAction),
			}
			items = append(items, mEvent)
		}
	}

	return items, nil
}
