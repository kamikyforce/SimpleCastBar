# SimpleCastBar Proximity Detection - TODO List

Based on our discussion about implementing proximity-based blind detection, here's a comprehensive TODO list for the feature:

## 🎯 Core Proximity Detection Features

### Phase 1: Basic Range Detection
- [ ] **Research WoW 3.3.5a distance functions**
  - [ ] Test `CheckInteractDistance()` availability and accuracy
  - [ ] Investigate `UnitPosition()` for manual distance calculation
  - [ ] Document range limitations and precision

- [ ] **Implement basic range checking system**
  - [ ] Create `IsTargetInBlindRange()` function
  - [ ] Add range detection to update loop
  - [ ] Test with different distance thresholds (5-8 yards)

### Phase 2: Blind Spell Database
- [ ] **Expand spell database for blind-type abilities**
  - [ ] Rogue: Blind (2094), Gouge (1776)
  - [ ] Warrior: Intimidating Shout (5246)
  - [ ] Priest: Psychic Scream (8122)
  - [ ] Warlock: Howl of Terror (5484)
  - [ ] Hunter: Intimidation (19577)

- [ ] **Add range specifications per spell**
  - [ ] Define optimal ranges for each blind ability
  - [ ] Create spell-specific proximity thresholds

### Phase 3: Visual & Audio Alerts
- [ ] **Proximity warning system**
  - [ ] Visual indicator on cast bar when enemies in range
  - [ ] Color-coded distance warnings (green/yellow/red)
  - [ ] Optional audio alerts for proximity

- [ ] **UI enhancements**
  - [ ] Add proximity indicator to existing cast bar
  - [ ] Create toggle options for proximity features
  - [ ] Implement range circle overlay (advanced)

### Phase 4: Advanced Features
- [ ] **Multi-target proximity detection**
  - [ ] Scan nearby enemies within blind range
  - [ ] Priority system for multiple threats
  - [ ] Group/raid member proximity alerts

- [ ] **Class-specific optimizations**
  - [ ] Auto-detect player class
  - [ ] Show relevant blind spells only
  - [ ] Customize alerts per class abilities

### Phase 5: Configuration & Polish
- [ ] **Slash command extensions**
  - [ ] `/scb proximity on/off` - Toggle proximity detection
  - [ ] `/scb range <yards>` - Set custom range threshold
  - [ ] `/scb alerts <type>` - Configure alert types

- [ ] **Settings persistence**
  - [ ] Save proximity settings to SavedVariables
  - [ ] Add proximity options to existing config system
  - [ ] Create user-friendly configuration interface

### Phase 6: Testing & Optimization
- [ ] **Performance testing**
  - [ ] Optimize update frequency for proximity checks
  - [ ] Test with multiple enemies in range
  - [ ] Ensure minimal FPS impact

- [ ] **PvP scenario testing**
  - [ ] Test in battlegrounds and arena
  - [ ] Validate accuracy in high-movement situations
  - [ ] Test with stealth detection

## 📋 Implementation Priority

**High Priority:**
1. Basic range detection research and implementation
2. Core proximity warning system
3. Integration with existing cast bar

**Medium Priority:**
4. Expanded blind spell database
5. Visual/audio alert system
6. Configuration options

**Low Priority:**
7. Advanced multi-target detection
8. Class-specific optimizations
9. Range circle overlay

## 🔧 Technical Considerations

- **WoW 3.3.5a Compatibility**: Ensure all distance functions work in this version
- **Performance**: Minimize CPU usage with efficient update intervals
- **User Experience**: Make alerts helpful but not intrusive
- **Customization**: Allow users to disable/configure proximity features

## 📝 Notes

- This feature will transform SimpleCastBar from a cast detection addon into a comprehensive proximity awareness tool
- Focus on PvP scenarios where blind detection is most critical
- Maintain backward compatibility with existing cast bar functionality
- Consider creating a separate module for proximity features to keep code organized

---

**Last Updated**: [Current Date]
**Status**: Planning Phase
**Next Action**: Research WoW 3.3.5a distance detection APIs