# Research: Declarative Dell S2725QC audio preference

## Summary
The S2725QC has two integrated 5 W speakers. For the clarified **declarative-only** requirement, WirePlumber’s supported `monitor.alsa.rules`/`priority.session` mechanism can prefer the detected HDMI sink; this does **not** guarantee that Vesktop enumerates the monitor or moves a pinned stream.

**Parent-verified local facts (not independently inspected):** PipeWire 1.6.9, WirePlumber 0.5.17; monitor sink 56, `Radeon Digital Stereo (HDMI 4) [DELL S2725QC]`, node `alsa_output.pci-0000_c1_00.1.hdmi-stereo-extra3`, unmuted 40%, priority 600; laptop sink 58 is default, priority 1009; Vesktop is linked to laptop; services active. **Screenshot-confirmed:** the monitor is listed in Vesktop as `Radeon High Definition Audio Controller Digital Stereo (HDMI 4) [DELL S2725QC]`; `System Default` is selected. There is no demonstrated enumeration bug. ALSA ELD reports DisplayPort, valid stereo LPCM support. These facts do not establish audible playback or hardware failure.

## Findings
1. **Claim: The monitor has its own speaker controls.** Dell documents `2 x 5 W` integrated speakers. Rear joystick → Menu → Audio exposes Volume (0–100), Speaker (Figure 49 shows On), and Audio Profiles. For eventual playback verification, check Speaker On and a moderate OSD volume; PipeWire’s 40% does not establish the OSD setting. No monitor setting was changed by this research. **Sources:** [Dell User’s Guide](https://dl.dell.com/content/manual22980564-dell-s-27-4k-usb-c-monitor-s2725qc-user-s-guide.pdf?language=en-us), “Product features,” “Using the joystick control,” Audio/Figure 49. **Support:** direct evidence; checking both controls is researcher recommendation. **Confidence:** high.

2. **Claim: A narrow ALSA rule is the supported declarative preference.** Proposed WirePlumber configuration content, for the parent to represent through the repository’s existing NixOS configuration mechanism:
   ```ini
   monitor.alsa.rules = [
     {
       matches = [
         {
           media.class = "Audio/Sink"
           alsa.name = "DELL S2725QC"
         }
       ]
       actions = {
         update-props = { priority.session = 1200 }
       }
     }
   ]
   ```
   `1200` is a researcher-chosen value: above laptop 1009, below the documented warning threshold of 1500 (larger sink priorities can make the sink monitor become the default source). Matching the sink class and exact monitor model avoids tying the preference to a PCI address or output profile. Both properties exist before rule application in installed WirePlumber 0.5.17 `scripts/monitors/alsa.lua:292–390`; properties in a single match object are ANDed. This is preference among available nodes, not forced hardware creation or application enumeration. **Sources:** [Official ALSA rules documentation](https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration/alsa.html#rules), [0.5.17 ALSA documentation source](https://gitlab.freedesktop.org/pipewire/wireplumber/-/raw/0.5.17/docs/rst/daemon/configuration/alsa.rst). **Support:** direct evidence for matching/update-props/priority; chosen value and application to this node are researcher inference. **Confidence:** high for mechanism; deployment untested.

3. **Claim: Saved defaults can defeat that priority rule.** `wpctl set-default` normally remembers a manual selection in `default-nodes`, which outranks priority-based choice. This explains why priority alone must not be promised to override an existing saved laptop selection; the parent found no `default.configured.audio.sink` metadata and no `default-nodes` state file in this session. Disabling persistence is therefore not justified by the observed state. For a strictly priority-driven declarative policy, the official setting is:
   ```ini
   wireplumber.settings = {
     node.restore-default-targets = false
   }
   ```
   **Only add this if that policy is intended/necessary:** it disables remembered source **and** sink defaults/history globally, not just the laptop’s default. Runtime manual selections remain respected while running, but are not remembered for later restoration. With normal persistence enabled, earlier user selections participate in fallback; with it disabled, available-node priorities decide. There is no basis for deleting state or using runtime switches here. **Sources:** [wpctl set-default](https://pipewire.pages.freedesktop.org/wireplumber/man/wpctl.html#set-default), [0.5.17 settings source](https://gitlab.freedesktop.org/pipewire/wireplumber/-/raw/0.5.17/docs/rst/daemon/configuration/settings.rst), [default-node hooks](https://pipewire.pages.freedesktop.org/wireplumber/scripting/existing_scripts/default_nodes.html#hooks). **Support:** direct evidence; conditional configuration recommendation is interpretation. **Confidence:** high for documented behavior, conditional locally.

4. **Claim: Default preference and existing-stream routing are different.** `set-default` documents new auto-connected streams. Separately, `linking.follow-default-target=true` (default) permits qualifying client streams to follow a changed default, including streams explicitly targeting the current default. Explicit non-default targets and restored per-application targets can retain another sink; `node.stream.restore-target=true` normally restores manually moved stream destinations. Thus neither “all existing streams move” nor “only new streams can move” is generally correct. Unavailable targets ordinarily fall back/reconnect, but stream properties such as `node.dont-fallback`/`node.dont-reconnect` can prevent this. No extra stream-policy override is justified without inspecting Vesktop’s target. **Sources:** [0.5.17 settings source](https://gitlab.freedesktop.org/pipewire/wireplumber/-/raw/0.5.17/docs/rst/daemon/configuration/settings.rst), [linking policy](https://pipewire.pages.freedesktop.org/wireplumber/policies/linking.html#stream-node-linking-properties). **Support:** direct evidence; recommendation to avoid additional overrides is researcher inference. **Confidence:** high for policy, uncertain for Vesktop’s present stream.

5. **Claim: Vesktop already lists the monitor; the selected default routes to the laptop.** The user's screenshot confirms the Radeon/HDMI 4 entry includes `[DELL S2725QC]`, while `System Default` is selected. The parent independently observed Vesktop's PulseAudio playback sink as 58 (laptop), not 56 (Dell). This resolves the reported missing-device question without an application patch. Discord documents the output selector, and WirePlumber documents `node.description` as the label most UIs display. **Sources:** user screenshot and live `pactl`/`wpctl` inspection; [Discord voice guide](https://support.discord.com/hc/en-us/articles/33030151293079-Discord-Voice-Video-Streaming-Guide), [0.5.17 ALSA source](https://gitlab.freedesktop.org/pipewire/wireplumber/-/raw/0.5.17/docs/rst/daemon/configuration/alsa.rst). **Confidence:** high for enumeration and current routing; actual monitor sound untested.

## Contradictions
None in the core mechanisms. Latest rendered priority examples use 3000, while ALSA documentation warns against sink priorities above 1500; the proposed 1200 avoids that tension. Rendered WirePlumber pages currently identify 0.5.18, so version-tagged 0.5.17 source was also fetched for rules/settings.

## Missing evidence / residual risks
- Following research, the user approved implementation. `modules/hosts/framework/default.nix` now defines the narrow rule through the pinned NixOS module's `services.pipewire.wireplumber.extraConfig`. No runtime switch has been performed. Services are already enabled through NixOS's graphical desktop defaults. Live Vesktop properties and saved stream properties showed no explicit target override.
- The rule matches the reported monitor model, not an individual unit: two S2725QC displays both qualify. Adapters that change or omit the reported name can defeat matching; hotplug and cross-port behavior still need testing.
- The screenshot resolves the enumeration question. OSD state, post-change routing, reconnect behavior and audible output remain untested; no hardware-failure conclusion is warranted.
- `source_check` retrieved passages but semantic validation was unavailable/unclear; retained original sources were manually inspected instead.

## Sources
- **Kept:** Dell official manual; WirePlumber official rules/settings (including 0.5.17-tagged source), wpctl/default-node/linking docs; Discord voice guide; Vesktop upstream README — exact URLs above.
- **Rejected/deprioritized:** third-party PDF mirror, Dell MacBook community thread, Vesktop issue reports, Arch/Fedora summaries — official sources suffice and unrelated reports cannot diagnose this setup.

## Next steps
The narrow priority rule is implemented; default persistence is unchanged and no scripts were added. Leave Vesktop on System Default. Activate through the repository's `just switch` when ready (this rebuilds/switches the host and may interrupt audio). After activation, run `wpctl status`: the default sink and Vesktop playback links should point to the Dell. Confirm audible playback, then test unplug/reconnect fallback. Check the monitor's own Speaker/Volume controls if correctly routed playback is silent.
