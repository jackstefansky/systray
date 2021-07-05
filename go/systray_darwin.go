// +build darwin

package systray

import (
	"fmt"

	"github.com/jackstefansky/trayhost"
)

func (p *SystrayPlugin) updateMenu(actions []SystrayAction) {
	items, err := p.actionsToMenu(actions)
	if err != nil {
		fmt.Println("An error has occurred while registering actions", err)
	}

	trayhost.UpdateMenu(items)
}

func initialize(title string, iconData []byte) {
	trayhost.Initialize(title, iconData, nil)
}

func updateStatusItemIcon(iconData []byte) {
	trayhost.UpdateStatusItemIcon(iconData)
}
