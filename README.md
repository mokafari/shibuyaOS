# Shibuya OS - Audio-Visual Cyberdeck Project

Shibuya OS är ett anpassat Linux-operativsystem baserat på Raspberry Pi OS, designat för att driva en portabel audio-visuell (A/V) cyberdeck. Målet är att skapa en optimerad och robust plattform för realtidsljudbearbetning, dynamiska visuella effekter (projectM), synkroniserad LED-belysning (LedFx) och videostreaming (OBS/NDI).

Cyberdäcket är tänkt att användas i krävande miljöer såsom utomhusspelningar och prioriterar prestanda, modularitet och en skräddarsydd användarupplevelse.

## Status

Detta repository innehåller för närvarande grunden för att bygga en första "dev mode" version av Shibuya OS för en Raspberry Pi Compute Module 4 (CM4) eller Raspberry Pi 5 (arm64). Denna grundavbildning inkluderar:
*   Standard Raspberry Pi OS Bookworm (64-bitars) bas.
*   Förinstallerade paket för grundläggande systemhantering, nätverk, och utveckling.
*   Mediepaket som `ffmpeg`, `pipewire`, `wireplumber`, `build-essential`, och `cmake` för att förbereda för framtida integration av NDI-streaming, projectM och LedFx.
*   En standardanvändare `shibuya` (lösenord: `shibuya` - **ändra detta för produktion!**).
*   SSH aktiverat som standard.

## Bygginstruktioner

För att bygga Shibuya OS-avbildningen behöver du:
1.  En macOS-dator (testat på).
2.  [UTM](https://mac.getutm.app/) virtualiseringsprogramvara.
3.  En Debian Linux VM (t.ex. Debian 11 "Bullseye" eller 12 "Bookworm") som körs i UTM.

### Steg för att bygga:

1.  **Förbered Debian VM:**
    *   Installera UTM på din Mac.
    *   Ladda ner och installera en Debian (arm64 för M1/M2 Mac, eller amd64 om du kör på Intel Mac och virtualiserar en amd64 Debian) VM i UTM.
    *   Konfigurera nätverket för VM:en (t.ex. "Emulated VLAN" med port forward från macOS port `22022` till VM port `22`) så att du kan SSH:a in.
    *   Starta VM:en, logga in, uppdatera systemet (`sudo apt update && sudo apt upgrade -y`) och installera `git` (`sudo apt install git -y`).

2.  **Klona detta Repository till din Debian VM:**
    Logga in på din Debian VM via SSH (t.ex. `ssh användarnamn@vm_ip -p port`).
    ```bash
    git clone <URL_TILL_DITT_NYA_GITHUB_REPO>
    cd <NAMN_PÅ_REPO_KATALOGEN> # t.ex. shibuyaOS
    ```

3.  **Gör byggskriptet körbart:**
    ```bash
    chmod +x build_rpios/debian_vm_scripts/start_shibuya_build.sh
    ```

4.  **Kör byggskriptet:**
    Du kommer att bli ombedd att ange ditt `sudo`-lösenord under installationen av beroenden.
    ```bash
    ./build_rpios/debian_vm_scripts/start_shibuya_build.sh
    ```
    Byggprocessen kan ta lång tid (30 minuter till flera timmar).

5.  **Hitta OS-avbildningen:**
    När bygget är klart kommer den färdiga `.img`-filen att finnas i en underkatalog som heter `deploy` inuti `rpi-image-gen`-katalogen (som skriptet klonar i din hemkatalog på VM:en, t.ex. `~/rpi-image-gen/deploy/`).

## Framtida Mål

*   Fullständig integration av NDI-streaming för OBS.
*   Installation och konfiguration av projectM för ljudvisualisering.
*   Installation och konfiguration av LedFx för LED-synkronisering.
*   Integration med PipeWire för avancerad ljudhantering.
*   Utveckling av en centraliserad kontrollpanel.
*   Optimering för dual display-system (huvud-LCD och sekundär OLED).

## Bidrag

Information om hur man kan bidra kommer senare. 