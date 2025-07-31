# SimpleCastBar

![SimpleCastBar in Action](https://i.imgur.com/mvmUHK6.jpeg)

A lightweight, customizable cast bar addon for World of Warcraft 3.3.5a that provides early warning detection of important enemy spells, particularly crowd control abilities.

## 🎯 Features

### Spell Detection
- **Combat Log Detection**: Real-time tracking of critical spells
- **Dual Detection System**: Uses both combat log events and unit casting for maximum reliability
- **Supported Spells**: Seduction, Polymorph, Fear, Hex, Mind Control, Banish, Enslave Demon

### Visual Cast Bar
- **Color-Coded Spells**: Each spell type has unique colors for instant recognition
- **Real-time Progress**: Shows casting progress and remaining time
- **Caster Information**: Displays who is casting the spell
- **Customizable Position**: Drag-and-drop positioning with resize handles

### Performance Optimized
- **O(1) Hash Table Lookups**: Efficient spell detection
- **Minimal FPS Impact**: Optimized for competitive PvP scenarios
- **Smart Update Frequency**: 10 FPS updates instead of every frame

## 🚀 Installation

1. Download the addon files
2. Extract to your WoW addons folder:
   ```
   World of Warcraft 3.3.5a/Interface/Addons/SimpleCastBar/
   ```
3. Restart World of Warcraft
4. The addon will automatically load and display a confirmation message

## ⚙️ Configuration

### Basic Commands
```
/scb toggle          - Enable/disable the addon
/scb test [seconds]  - Interactive positioning mode (5-60s)
/scb position        - Quick 30-second positioning mode
/scb lock            - Lock/unlock position and resizing
/scb reset           - Reset position and size to defaults
```

### Customization
```
/scb scale <0.5-2.0>   - Set cast bar scale
/scb width <100-500>   - Set cast bar width
/scb height <15-50>    - Set cast bar height
```

## 🎮 Usage

### First Time Setup
1. Type `/scb test` to enter positioning mode
2. **Drag the cast bar** to your preferred location
3. **Drag corner handles** to resize if needed
4. Type `/scb lock` when satisfied with position

### In Combat
- The cast bar automatically appears when important spells are detected
- **Color coding** helps identify spell types instantly
- **Timer** shows remaining cast time for reaction planning
- **Caster name** identifies the threat source

## 🎨 Spell Colors

- **Seduction** - Purple/Magenta
- **Polymorph** - Blue
- **Fear** - Dark Purple
- **Mind Control** - Light Purple
- **Banish** - Orange
- **Enslave Demon** - Red
- **Hex** - Brown/Orange

## 🔧 Technical Details

### Compatibility
- **World of Warcraft 3.3.5a** (Wrath of the Lich King)
- Compatible with most other addons
- No external dependencies required

### Performance
- Optimized event handling with early returns
- Hash table lookups for O(1) spell detection
- Minimal memory footprint
- Efficient update frequency (10 FPS)

## 🎯 PvP Focus

This addon is specifically designed for **PvP scenarios** where:
- Split-second reactions to crowd control are crucial
- Early warning of incoming CC abilities provides tactical advantage
- Visual clarity helps in high-stress combat situations
- Reliable detection prevents missed interrupts or defensive cooldowns

## 📝 Commands Reference

| Command | Description |
|---------|-------------|
| `/scb` | Show all available commands |
| `/scb toggle` | Enable/disable addon |
| `/scb test [time]` | Interactive positioning (default 15s) |
| `/scb test stop` | End test mode early |
| `/scb position` | Quick positioning mode (30s) |
| `/scb hide` | Hide current cast bar |
| `/scb lock` | Toggle position lock |
| `/scb reset` | Reset to default settings |
| `/scb scale <value>` | Set scale (0.5-2.0) |
| `/scb width <value>` | Set width (100-500) |
| `/scb height <value>` | Set height (15-50) |

## 🐛 Troubleshooting

### Cast Bar Not Showing
1. Check if addon is enabled: `/scb toggle`
2. Verify the spell is in the supported list
3. Ensure you have a valid target/focus

### Position Issues
1. Use `/scb reset` to restore default position
2. Try `/scb test` for interactive repositioning
3. Check if the bar is locked: `/scb lock`

## 📄 License

MIT License - See LICENSE file for details

## 👤 Author

**Micael Santana**

---

*SimpleCastBar - Giving you the edge in PvP combat through superior spell awareness.*