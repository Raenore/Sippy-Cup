# Sippy Cup 🥤

**Sippy Cup** tracks and reminds you of your roleplay consumables and toys, helping keep you focused on what matters most: *Roleplay*.  
Available on [CurseForge](https://www.curseforge.com/wow/addons/sippy-cup), [Wago.io](https://addons.wago.io/addons/sippy-cup) and [WoWInterface](https://www.wowinterface.com/downloads/info26933-SippyCup.html)!  

## 🛠️ How It Works

Once enabled, Sippy Cup will display a reminder popup when:
- Your consumable runs out (or is about to, if that option is enabled).  
- Your current stack count falls below your desired amount.  
- You lack the necessary item(s) for your next refresh.

![Popups](Previews/Popups/Popups.png)

**Note:** On login, a popup will appear for tracked consumables/toys with active stacks. If the **Only when "In Character"** option is enabled, it will also remind you about inactive stacks.

If multiple consumables/toys expire simultaneously, Sippy Cup will display multiple popups.  
Once you have 5 popups active, additional ones will be queued and shown as you dismiss or resolve existing ones.

![Multi-Popups](Previews/Multi-Popups/Multi-Popups.png)

If an item cannot be refreshed because it’s either missing from your inventory or you don’t have enough units or stacks to reach your desired amount, the refresh button will display a warning-colored tooltip.

<table>
  <tr>
    <td><img src="https://i.imgur.com/7KxqNRB.png" alt="Missing Item Example - Classic"></td>
	<td><img src="https://i.imgur.com/C6fSCxb.png" alt="Missing Item Example - ElvUI"></td>
  </tr>
  <tr>
    <td><img src="https://i.imgur.com/kYPjFop.png" alt="Low Amount Icon - Classic"></td>
    <td><img src="https://i.imgur.com/0FGuN67.png" alt="Low Amount Icon - ElvUI"></td>
  </tr>
</table>

If the **Insufficient Reminder** option is enabled (disabled by default), Sippy Cup will remind you if you don't have enough of the item for your next refresh.

<table>
  <tr>
    <td><img src="https://i.imgur.com/LRPxfHJ.png" alt="Insufficient reminder - Classic"></td>
    <td><img src="https://i.imgur.com/eAp1Wdm.png" alt="Insufficient reminder - ElvUI"></td>
  </tr>
</table>

## ⚙️ General Settings

Adjust Sippy Cup's settings to match your personal preferences by using `/sc` or `/sippycup`.

Here you can:  
- Toggle a **Startup message** at login.  
- Control the visibility of the **Minimap button**.  
- Configure integration with the **Addon compartment** of UI mods.

The **Reminder Popups** section offers detailed control over how reminders appear:  
- **Pre-expiration Reminder** to notify you before items expire (only for supported consumables/toys).  
- **Insufficient Reminder** to alert you when you don’t have enough items for the next refresh.  
- **Customize their position** on the screen (Top, Center, or Bottom).  
- Choose a **sound** for reminders and decide if they should **flash your taskbar**.

Sippy Cup also offers special integration:  
- **Only when "In Character"**: Limits Sippy Cup's checks and reminders to times when your character is recognized as "In Character".  
  (Requires an RP profile addon like TRP3, MRP, XRP, etc.)

At the bottom of this page, you’ll find information about your current version of Sippy Cup.

![Main - General](Previews/Main/MainGeneral.png)

## 📦 Reminder Categories

![Categories](Previews/Categories/Categories.png)

Sippy Cup supports a variety of consumable categories:
- **Appearance:** Alters your character’s visual appearance.  
- **Effect:** Applies a temporary effect to your character or the environment.  
- **Handheld:** Places an item in your character’s hand(s).  
- **Placement:** Creates objects in the game world.  
- **Prism:** Changes your appearance.  
- **Size:** Alters your character’s size.

[Click here for a complete list of supported consumables/toys](https://github.com/Raenore/Sippy-Cup/wiki#supported-options).

Below you can find a screenshot of the **Size** category for reference.

![Main - Size](Previews/Main/MainSize.png)
