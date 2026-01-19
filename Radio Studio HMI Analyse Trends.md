# **Radio Studio HMI Analyse: Eine umfassende Untersuchung von Hardware, GUI, Ergonomie und zukünftigen Trends**

## **1\. Einleitung: Die Evolution der Schnittstelle im modernen Rundfunk**

Das Radiostudio befindet sich in einer Phase tiefgreifender technologischer Transformation. Was einst eine Ansammlung diskreter, analoger Hardwarekomponenten war, hat sich zu einer hochintegrierten, vernetzten Umgebung entwickelt, in der Software und Hardware nahtlos ineinandergreifen. Im Zentrum dieses Ökosystems steht das Human-Machine Interface (HMI) – die Schnittstelle zwischen dem Menschen (Moderator, Produzent, Redakteur) und der immer komplexer werdenden Sendetechnik. Diese Analyse widmet sich einer erschöpfenden Betrachtung des Radio-HMIs unter Berücksichtigung der haptischen Steuerelemente, der grafischen Benutzeroberflächen (GUIs), der ergonomischen Anforderungen sowie der disruptiven Trends, die die Arbeitsweise im Studio bis zum Jahr 2030 prägen werden.

Historisch betrachtet war das Mischpult das unbestrittene Zentrum der Interaktion. Seine Funktion war klar definiert: Die Summierung und Pegelung von Audiosignalen. In der heutigen Ära von Audio-over-IP (AoIP) und softwarebasierten DSP-Kernen hat sich die Rolle des Mischpults fundamental gewandelt. Es ist nicht mehr der Ort, an dem Audio physisch fließt, sondern eine komplexe Fernbedienung für Prozesse, die in Serverräumen oder zunehmend in der Cloud stattfinden.1 Diese Entkopplung von Steuerung und Verarbeitung ermöglicht radikal neue HMI-Konzepte, von der vollständigen Virtualisierung bis hin zu hybriden Ansätzen, die Touchscreens mit traditioneller Haptik verbinden.

Die Relevanz einer detaillierten HMI-Analyse ergibt sich aus der steigenden kognitiven Belastung der Operatoren. Der moderne "Self-Op"-Moderator ist nicht mehr nur Diskjockey; er ist Multimedia-Produzent, der gleichzeitig Audio mischt, Visual Radio-Kameras steuert, Social-Media-Feeds kuratiert und komplexe Automationssysteme überwacht. Ein schlecht gestaltetes HMI führt in diesem Umfeld nicht nur zu Fehlbedienungen, sondern zu Ermüdung und einer Minderung der inhaltlichen Qualität der Sendung. Daher untersuchen wir, wie führende Hersteller wie DHD Audio, Lawo, Telos Alliance (Axia) und Wheatstone durch innovative Designs versuchen, diese Komplexität beherrschbar zu machen.

## ---

**2\. Hardware HMI: Die Renaissance der taktilen Kontrolle**

Trotz der Omnipräsenz von Touchscreens in unserem Alltag bleibt die physische Hardware im Radiostudio unverzichtbar. Die Haptik bietet eine Rückmeldung, die flache Bildschirme nicht simulieren können: die Sicherheit der "blinden" Bedienung. Ein Moderator muss in der Lage sein, einen Regler zu ziehen oder einen Knopf zu drücken, während er Augenkontakt mit einem Interviewpartner hält oder ein Skript liest.

### **2.1 Fader-Technologie als primäres Steuerelement**

Der Fader (Schieberegler) ist das definierende Element des Radio-HMI. Seine Qualität, sein Widerstand und seine technische Ausführung bestimmen maßgeblich das "Gefühl" der Kontrolle.

#### **2.1.1 Motorisierung und Layer-Logik**

Ein entscheidender Trend in der Hardware-Entwicklung ist der fast flächendeckende Einsatz von motorisierten 100-mm-Fadern in professionellen Konsolen, wie sie von DHD Audio (Series 52/RX2, SX2) 1 und Lawo (diamond, ruby) 4 verbaut werden. Die Motorisierung ist keine Spielerei, sondern eine funktionale Notwendigkeit für moderne Workflows.

In Zeiten, in denen Studioimmobilien teurer werden und Möbel kleiner ausfallen müssen, erlauben motorisierte Fader das Konzept des "Layering" (Ebenenumschaltung). Ein kompaktes Mischpult mit nur 12 physischen Fadern kann durch Umschalten der Ebenen 24, 36 oder mehr Quellen steuern. Ohne Motoren wäre dies ergonomisch katastrophal: Schaltet der Nutzer von Ebene A auf Ebene B, würden die physischen Fader nicht mit den tatsächlichen Pegeln der neuen Ebene übereinstimmen. Der Nutzer müsste sie erst manuell "abholen" (Nulling), was in einer Live-Situation fehleranfällig ist. Motorfader hingegen springen sofort in die korrekte Position und visualisieren den Status der neuen Ebene instantan.1

Darüber hinaus ermöglicht die Motorisierung eine bidirektionale Kommunikation mit der Playout-Automation. Wenn das Sendesystem (z.B. mAirList oder RCS Zetta) einen Musiktitel automatisch ausblendet, bewegt sich der Fader am Pult entsprechend. Dies synchronisiert die visuelle Wahrnehmung des Moderators mit der auditiven Realität und verhindert kognitive Dissonanzen.

Im Kontrast dazu steht der Ansatz von Axia bei der Quasar SR Konsole, die in der Standardausführung auf motorisierte Fader verzichtet, um Kosten zu senken und mechanische Komplexität zu reduzieren. Hier verlässt man sich auf "Confidence Class Metering" und hochauflösende Displays, um den Status anzuzeigen.6 Dies stellt einen Kompromiss dar, der in weniger komplexen Umgebungen akzeptabel sein mag, aber in dynamischen Sendesituationen die mentale Last erhöht, da der haptische Status nicht immer dem akustischen entspricht.

#### **2.1.2 Berührungsempfindlichkeit (Touch Sensitivity)**

Moderne Fader fungieren zunehmend als kapazitive Sensoren. Hersteller wie Lawo integrieren diese Technologie tief in die Bedienphilosophie. Sobald ein Finger den Faderknopf berührt, kann das System Kontextinformationen auf dem assoziierten Bildschirm anzeigen, noch bevor der Fader bewegt wird.

* **Touch-to-Access:** Bei der Lawo diamond Konsole öffnet die bloße Berührung eines Faders beispielsweise das Equalizer- oder Dynamik-Menü für diesen Kanal auf dem zentralen Touchscreen. Dies eliminiert den früher notwendigen "Select"-Knopfdruck und beschleunigt den Workflow erheblich.5  
* **Logische Verknüpfungen:** Auch bei Axia Quasar Konsolen sind Fader und Drehregler berührungsempfindlich.7 Dies kann genutzt werden, um temporäre Gruppierungen aufzulösen oder spezielle Abhörwege (PFL) zu aktivieren, ohne dass ein separater Taster betätigt werden muss.

### **2.2 Drehgeber (Encoder) und kontextsensitive Steuerung**

Der klassische Potentiometer mit festem Anschlag ist im digitalen Studio fast vollständig durch Endlos-Drehgeber (Encoder) ersetzt worden. Diese bieten eine wesentlich höhere Flexibilität im HMI-Design.

#### **2.2.1 Visuelles Feedback durch LED-Ringe und Displays**

Da ein Endlos-Regler keine physische Position hat, die einen Wert anzeigt, ist visuelles Feedback essenziell. Hochwertige Konsolen nutzen LED-Kränze um den Regler herum.

* **Farbkodierung:** Lawo nutzt RGB-LEDs, um die Funktion des Reglers farblich zu kodieren (z.B. Blau für Panorame, Rot für Gain, Grün für Equalizer-Parameter). Dies nutzt die präattentive Wahrnehmung des Menschen: Das Auge erkennt die Farbe und damit die Funktion schneller, als es Text lesen kann.5  
* **OLED-Integration:** Bei DHD Audio und Wheatstone finden sich oft kleine OLED-Displays direkt neben oder über den Encodern, die den aktuellen Parameterwert und die Funktion im Klartext anzeigen.1 Dies ist besonders wichtig bei multifunktionalen Reglern, die je nach Modus völlig unterschiedliche Aufgaben übernehmen (z.B. Kopfhörerlautstärke vs. Mikrofonvorverstärkung).

### 

### **2.3 Schaltertechnologie und Programmierbarkeit**

Der "Knopf" im Radiostudio muss spezifische Anforderungen erfüllen: Er muss absolut lautlos schalten (um nicht über offene Mikrofone hörbar zu sein), aber dennoch einen deutlichen Druckpunkt bieten.

#### **2.3.1 RGB-Hinterleuchtung und Statusanzeige**

Die Ära der fest beschrifteten Tasten ist vorbei. Moderne Konsolen wie die Wheatstone LXE setzen auf vollständig programmierbare Tasten mit RGB-Hinterleuchtung.9

* **Dynamische Farbgebung:** Ein Taster kann seinen Status durch Farbwechsel anzeigen: Grün für "Bereit", Rot für "On Air", Blinkend Gelb für "Warnung". Diese visuelle Sprache ermöglicht es dem Operator, den Status des gesamten Studios mit einem einzigen Blick zu erfassen.  
* **Software-Definition:** Über Tools wie den "ConsoleBuilder™" von Wheatstone kann jeder physische Knopf auf der Oberfläche mit individuellen Skripten belegt werden.8 Ein Knopf könnte morgens als "Wetterbett starten" fungieren und abends als "Studioverbindung trennen".

#### **2.3.2 OLED-Tasten (Smart Keys)**

Ein Schritt weiter in der HMI-Evolution sind Tasten mit integrierten Miniatur-Displays (LCD oder OLED), wie sie bei High-End-Systemen von Lawo oder in speziellen Sprechstellen von Riedel (oft in Kombination genutzt) zu finden sind. Diese Tasten ändern nicht nur ihre Farbe, sondern auch ihre Beschriftung dynamisch. Dies löst das Problem der "Mystery Buttons" auf generischen Bedienoberflächen.

### **2.4 Periphere Hardware: Dezentralisierung des HMI**

Das HMI endet nicht am Mischpult. Für Gäste, Co-Moderatoren und Produzenten existieren spezialisierte Hardware-Schnittstellen, die Teil des Gesamtsystems sind.

#### **2.4.1 Talent Stations und Gast-Steuerung**

In modernen "Co-Host"-Szenarien oder bei Talk-Formaten ist es ergonomisch ungünstig, wenn der Hauptmoderator auch die Kopfhörermischung für alle Gäste steuern muss. "Talent Stations" wie die Wheatstone TS-22 oder TS-4 dezentralisieren diese Funktion.10

* **Psychologische Ergonomie:** Ein Gast, der seine eigene Lautstärke regeln kann, fühlt sich wohler und spricht natürlicher. Die TS-22 bietet zudem programmierbare Tasten, mit denen ein Co-Moderator beispielsweise sein eigenes Mikrofon stummschalten ("Räuspertaste") oder eine Talkback-Verbindung zum Produzenten aufbauen kann, ohne den Hauptmoderator zu stören.  
* **Konnektivität:** Diese Geräte sind heute meist IP-basiert (Power over Ethernet), was die Verkabelung reduziert und eine flexible Platzierung am Studiotisch ermöglicht.

#### **2.4.2 Die "Husten-Taste" (Cough Button)**

Ein scheinbar triviales, aber kritisches HMI-Element ist die Räuspertaste.

* **Logik:** Hardware wie der "Guest Gizmo" von Angry Audio oder Module von StudioHub implementieren eine spezifische Logik.12 Im Gegensatz zu einem Ein/Aus-Schalter ist die Husten-Funktion immer temporär (Push-to-Mute). Dies verhindert, dass ein Mikrofon versehentlich stummgeschaltet bleibt.  
* **GPIO-Integration:** Professionelle Lösungen triggern nicht nur die Stummschaltung, sondern senden auch ein Signal an die Automation oder den Logger, um diese "Stille" nicht als Sendeloch zu interpretieren.14

## ---

**3\. Graphical User Interface (GUI): Die visuelle Ebene**

Mit der zunehmenden Komplexität der Funktionen verlagern sich viele Aufgaben von der physischen Oberfläche auf Bildschirme. Das GUI-Design ist entscheidend für die Effizienz und Fehlervermeidung.

### **3.1 Integrierte Touchscreens im Mischpult**

Ein dominanter Trend ist die Verschmelzung von Fader-Modulen und Touchscreens.

* **DHD Audio:** Die SX2 und RX2 Serien integrieren 10,1-Zoll-Multitouch-Displays direkt oberhalb der Fader.1 Diese Bildschirme zeigen Pegelmeter, Uhren und kontextbezogene Einstellungen an. Die vertikale Anordnung (Fader unten, Display oben) erhält den klassischen "Kanalzug"-Charakter, nutzt aber die Flexibilität von Software.  
* **Axia Quasar:** Hier kommt ein 12,1-Zoll-Master-Touchscreen in Industriequalität zum Einsatz.7 Dieser dient als zentrale Kommandozentrale für tiefere Systemeinstellungen, Routing und Processing (EQ-Kurven), die auf der physischen Oberfläche zu viel Platz einnehmen würden.

Die Herausforderung bei integrierten Touchscreens ist die Latenz und die Zuverlässigkeit. Broadcast-GUIs müssen nahezu verzögerungsfrei reagieren (\<10 ms), um sich "echt" anzufühlen. DHD setzt hierbei auf dedizierte DSP-basierte Grafikverarbeitung, um Unabhängigkeit von PC-Betriebssystemen zu gewährleisten.2

### **3.2 Virtuelle Konsolen und Software-Interfaces**

Softwarelösungen wie Lawo VisTool 15 oder Wheatstone ScreenBuilder 17 erlauben die Erstellung komplett virtualisierter HMIs.

* **Rollenbasierte Ansichten:** Mit VisTool Unlimited können Sender maßgeschneiderte Oberflächen für verschiedene Nutzergruppen entwerfen. Ein "DJ-Modus" zeigt vielleicht nur 4 Fader und eine Cartwall, während ein "Technik-Modus" Zugriff auf alle Routing-Matrizen und DSP-Parameter gewährt.  
* **Remote-Betrieb:** Diese GUIs sind nativ netzwerkfähig. Ein Moderator kann die Sendung von zu Hause aus über ein Tablet steuern, das via VPN mit dem Core im Funkhaus verbunden ist. Das GUI auf dem Tablet ist dabei identisch oder angepasst an die mobile Nutzung, steuert aber dieselbe Hardware.18

### **3.3 Playout- und Automations-GUIs**

Das Automationssystem ist das Werkzeug, mit dem der Moderator die meiste Zeit interagiert. Die GUI-Gestaltung hier folgt strikten Prinzipien der "Glanceability" (Erfassbarkeit auf einen Blick).

* **mAirList:** Das Design zeichnet sich durch eine hochgradig anpassbare "Cartwall" aus, die physische Jingle-Maschinen emuliert. Ein kritisches visuelles Element ist der "Progress Bar" und die "Backtiming"-Anzeige, die dem Moderator visuell signalisiert, ob die aktuelle Stunde zu lang oder zu kurz geplant ist.19 Die Farbwahl ist oft dunkel gehalten, um die Augen in dunklen Studios zu schonen, mit leuchtenden Farben (Rot/Grün/Gelb) nur für statuskritische Informationen.  
* **RCS Zetta:** Setzt auf "Floating Modules", die sich der Nutzer frei auf mehreren Bildschirmen anordnen kann.21 Die Integration geht so weit, dass Änderungen im Musikplaner (GSelector) sofort im Playout sichtbar sind. Die visuelle Darstellung von Wellenformen erlaubt ein präzises, visuelles "Voicetracking" (Aufzeichnen von Moderationen zwischen Songs), bei dem der Moderator die Übergänge optisch "zieht".22  
* **David Systems TurboPlayer:** Bei öffentlich-rechtlichen Sendern verbreitet, bietet der "OnAir TrackMixer" (OTM) eine Mehrspur-Ansicht direkt im Playout-Fenster.23 Dies bringt die Präzision einer DAW (Digital Audio Workstation) in den Live-Betrieb.

### **3.4 Visualisierung: Uhren, Metering und Signalisierung**

Neben der aktiven Steuerung ist die passive Informationsaufnahme essenziell.

* **Loudness Metering (EBU R128):** Die Ablösung der Peak-Meter (PPM) durch Loudness-Meter erfordert neue Visualisierungen. Da Loudness ein integrierter Wert über Zeit ist, nutzen GUIs oft "Radar"-Darstellungen (wie von TC Electronic populär gemacht) oder Histogramme, die den Verlauf der Lautheit über die letzten Sekunden oder Minuten zeigen.24 Dies hilft dem Moderator, die "Loudness Range" (LRA) visuell einzuschätzen und nicht nur Momentanwerte zu korrigieren.  
* **Signalisierung (Yellowtec litt):** Ein Paradebeispiel für Hardware-Visualisierung ist die "litt" Signalisierungssäule.26 Sie nutzt CleanVision-Technologie für eine 360-Grad-Sichtbarkeit. Die Farbcodierung (Rot \= On Air, Weiß blinkend \= Telefonanruf, Grün \= Mikrofon offen) kommuniziert den Studio-Status non-verbal an alle Anwesenden. Dies ist ein "Ambient HMI", das Informationen liefert, ohne dass man einen Fokuspunkt suchen muss.  
* **SmartSign / Screenabl:** Moderne Studiouhren sind digitale Dashboards. Sie integrieren Wetterdaten, Countdowns bis zum nächsten Element und Statusanzeigen (z.B. "Silence Detection Alarm") in einem Display.28

## ---

**4\. Ergonomie und Human Factors**

Ergonomie im Radiostudio umfasst weit mehr als bequeme Stühle. Es geht um die Optimierung der Interaktion zwischen Mensch und Technik unter Berücksichtigung physischer und kognitiver Belastungen.

### **4.1 Studio-Layout und Sichtlinien**

Die Anordnung der Hardware im Raum hat direkten Einfluss auf den Arbeitsfluss und die Kommunikation.

* **Self-Op vs. Co-Host:** In einem "Self-Op"-Studio, in dem der Moderator die Technik fährt, muss das Mischpult zentral (oft in Hufeisenform) platziert sein. Alle kritischen Elemente (Mikrofon-Fader, Cartwall-Touchscreen) müssen im "primären Greifraum" (ca. 40 cm Radius) liegen.30 Für Co-Host-Setups ist eine Positionierung "Face-to-Face" essenziell, um non-verbale Kommunikation zu ermöglichen.  
* **Sichtlinien und Visual Radio:** Mit dem Aufkommen von Kameras im Studio (Visual Radio) ändern sich die Anforderungen. Hohe Meterbridges oder Monitorwände stören die Kamerabilder und blockieren den Blickkontakt zwischen Moderatoren. Konsolen wie die Axia Quasar SR oder die Wheatstone GSX "Wedge" sind daher extrem flach profiliert ("Low Profile"), um freie Sichtachsen zu gewährleisten.6

### **4.2 Kognitive Belastung und Interface-Design**

Moderatoren müssen Multitasking auf hohem Niveau betreiben: Sprechen, Zuhören, Lesen, Bedienen.

* **Farbkodierung zur Reduktion der Suchzeit:** Konsolen wie die Lawo diamond nutzen konsistente Farbkodierungen über Fader, Bildschirme und Tasten hinweg (z.B. Gelb für Telefon). Dies reduziert die kognitive Last, da das Gehirn Farben schneller verarbeitet als Text.5  
* **Haptik vs. Touch:** Reine Touch-Interfaces erfordern visuelle Aufmerksamkeit, da man einen virtuellen Knopf nicht erfühlen kann. Dies lenkt vom Inhalt ab. Hybride HMIs (physische Fader für die Blindbedienung, Touch für Setup) sind daher der ergonomische Goldstandard.33 Studien zeigen, dass haptisches Feedback Fehlerquoten senkt und die Bedienungssicherheit erhöht, insbesondere in Stresssituationen (Breaking News).35

### **4.3 Physische Umgebungsergonomie**

* **Montagesysteme:** Monitorarme wie das Yellowtec m\!ka System erlauben eine dreidimensionale Positionierung von Bildschirmen und Mikrofonen.36 Dies ist wichtig, um das Studio an unterschiedliche Körpergrößen (5. bis 95\. Perzentil) anzupassen und Haltungsschäden vorzubeugen.  
* **Beleuchtung:** Blendfreie Beleuchtung und die Anpassung der Helligkeit von Displays und Tasten an das Umgebungslicht (durch Sensoren in Konsolen wie der Lawo diamond) verhindern Augenermüdung.5

## ---

**5\. Systemlogik und HMI-Intelligenz**

Das mächtigste HMI ist dasjenige, das komplexe Aufgaben automatisiert und unsichtbar macht.

### **5.1 Mix-Minus und Konferenzlogik**

Früher war das Erstellen einer "Mix-Minus"-Schaltung (ein Signal für den Anrufer, das alles enthält außer ihm selbst, um Echo zu vermeiden) eine komplexe manuelle Patch-Aufgabe.

* **Automatisierung:** Moderne AoIP-Systeme (Axia Livewire+, WheatNet-IP, Lawo) generieren diese Busse automatisch im Hintergrund.37 Wenn ein Fader einer Telefonquelle zugewiesen wird, erstellt das System dynamisch den passenden Rückweg (N-1). Das HMI für den Nutzer bleibt simpel: Fader hochziehen. Die Komplexität wird durch Systemlogik abstrahiert.  
* **Talkback-Logik:** Die "Talk"-Taste an einer Talent Station nutzt komplexe Logik, um Monitore zu dimmen (gegen Rückkopplung) und private Kommunikationswege zu öffnen, ohne dass der Operator Matrizen schalten muss.39

### **5.2 Protokollintegration (Ember+, ACI)**

Das HMI ist heute Frontend für das gesamte technische Netzwerk.

* **Ember+:** Dieses offene Protokoll, stark genutzt von Lawo und DHD, erlaubt es dem Mischpult, Drittgeräte zu steuern.41 Ein einziger Knopfdruck ("Studio On") kann über Ember+ das Licht dimmen, die Tür verriegeln, den Video-Stream starten und die Kreuzschiene schalten. Das HMI wird zur universellen Fernbedienung.  
* **WheatNet-IP ACI:** Ermöglicht tiefgreifende Skripting-Interaktionen. Wenn im Automationssystem ein Song startet, kann der Fader am Pult automatisch aufgehen (Faderstart). Umgekehrt kann der Faderstart am Pult den Player in der Software starten.43

## ---

**6\. Visual Radio Integration**

Radio wird multimedial. Das HMI muss Video steuern, ohne einen Bildmischer zu erfordern.

### **6.1 Audio-Follow-Video Automation**

Systeme wie MultiCAM Systems oder Broadcast Bionics integrieren sich tief in die Konsolenlogik.

* **Funktionsweise:** Die Software analysiert die Audiopegel der Mikrofone oder empfängt Fader-Status-Daten (GPO/Ember+).45 Wenn der Moderator spricht (Mikrofon offen und Pegel \> Threshold), schneidet das System automatisch auf seine Kamera. Sprechen mehrere Personen, wird eine Totale gewählt.  
* **HMI-Implikation:** Der Moderator "schneidet" das Video durch das Mischen des Audios. Es ist kein separates Video-HMI nötig. Dies ist ein ergonomischer Triumph, da eine komplexe Zusatzaufgabe (Bildregie) in einen bestehenden Arbeitsprozess (Audiomischung) integriert wird.47

### **6.2 Social Media Integration**

Tools wie Broadcast Bionics "Bionic Social" aggregieren WhatsApp, SMS und X (Twitter) in einer Oberfläche.

* **Workflow:** Produzenten können Nachrichten per Drag-and-Drop auf einen Bildschirm beim Moderator schieben.  
* **Signalisierung:** Eingehende VIP-Nachrichten können spezielle Lichtsignale auf der Yellowtec litt Säule auslösen (z.B. kurzes blaues Blinken), um den Moderator diskret zu informieren.48

## ---

**7\. Trends und Ausblick (2026-2030)**

Die Zukunft des Radio-HMIs liegt in der weiteren Virtualisierung, dem Einsatz von KI und neuen haptischen Technologien.

### **7.1 Virtualisierung und Cloud**

Der Trend geht zum "Headless Studio". Der DSP-Core (z.B. Lawo Power Core, DHD XC3) wandert ins Rechenzentrum oder die Cloud. Das "Studio" ist nur noch eine Bedienoberfläche (Tablet, HTML5-Browser).50

* **Browser-basierte HMIs:** Interfaces wie Lawo VisTool Web oder Axia Quasar Soft laufen im Browser. Dies macht das HMI geräteunabhängig. Ein iPad wird zum vollwertigen Mischpult.  
* **Pop-Up Studios:** Mit 5G und Cloud-Processing kann ein HMI überall aufgebaut werden, ohne schwere Hardware-Racks.52

### **7.2 KI-Integration im HMI**

Künstliche Intelligenz wird zum "Co-Piloten".

* **Voice Control:** "Voice GPIO" (Broadcast Bionics) ermöglicht Sprachbefehle wie "Mikrofon aus" oder "Musik starten".53 Dies reduziert die physische Interaktion.  
* **Prädiktive Unterstützung:** KI könnte den Sendeplan analysieren und das Pult für den nächsten Gast vorkonfigurieren (EQ-Profile laden, Routing setzen), sodass der Operator ein "bereites" Pult vorfindet.54

### **7.3 Haptisches Feedback in Glasoberflächen**

Um die Lücke zwischen Touchscreen und Taste zu schließen, könnten Technologien wie elektrostatische oder Piezo-Haptik Einzug halten. Diese lassen den Finger auf dem Glas eine Textur oder einen "Klick" spüren. Dies würde die Flexibilität von Displays mit der Sicherheit physischer Tasten verbinden.33

## ---

**8\. Vergleichende Analyse führender Systeme**

| Merkmal | DHD Audio (Series 52\) | Lawo (Diamond/Ruby) | Axia (Quasar) | Wheatstone (LXE/GSX) |
| :---- | :---- | :---- | :---- | :---- |
| **Fader-Technik** | Motorisiert 100mm 1 | Motorisiert, Touch-Sensitiv 5 | Touch-Sensitiv (SR: Non-motor, XR: Motor) 6 | Motorisiert, skriptbar via ACI 8 |
| **Display-Integration** | 10.1" Multitouch pro 4/6 Fader 1 | Virtuelle Extension (13.3"), VisTool 5 | 12.1" Master Touchscreen, TFTs pro Kanal 7 | Touchscreen GUI mit Gestensteuerung 8 |
| **Logik/Skripting** | DHD Toolbox Software 56 | VisTool Logic Engine, Ember+ 15 | Pathfinder Core PRO (Logic Flows) 57 | ConsoleBuilder™ (Skripting pro Taste) 8 |
| **Philosophie** | Modular, dezentral, Hardware-fokussiert. | "Phygital" (Physical \+ Digital), tief integriert in IP-WAN. | Industrielles Design, starker Fokus auf Touch-Sensoren. | Maximale Anpassbarkeit ("Jeder Knopf kann alles"). |

### **8.1 DHD Audio: Der modulare Pragmatiker**

DHD erlaubt extreme Modularität. Ein "Pult" kann aus drei getrennten Modulen bestehen, die frei auf dem Tisch platziert werden. Die 10,1-Zoll-Screens bieten exzellente Lesbarkeit direkt am Fader.1

### **8.2 Lawo: Die IP-Integration**

Lawo integriert das HMI tief in die IP-Infrastruktur. Die "Virtual Extension" erweitert den physischen Fader nahtlos auf den Bildschirm. Funktionen wie "AutoMix" verschieben das HMI vom "Regeln" zum "Managen".5

### **8.3 Axia: Der Touch-Pionier**

Axia setzt massiv auf kapazitive Sensoren. Das Pult "weiß", wenn eine Hand einen Regler berührt, und kann Modi umschalten. Dies ist ein "Intent-Based HMI".7

### **8.4 Wheatstone: Der Skript-Meister**

Wheatstone bietet mit ConsoleBuilder die tiefste Anpassbarkeit. Jeder Knopf kann komplexe Makros auslösen, was das HMI für den Endanwender stark vereinfachen kann, aber hohen Konfigurationsaufwand erfordert.9

## ---

**9\. Fazit**

Die Analyse zeigt, dass das ideale Radio-HMI heute ein **hybrides System** ist: Es kombiniert die **taktile Präzision** motorisierter Fader mit der **Flexibilität** von Touchscreens und der **Intelligenz** von Hintergrundlogik (Ember+, ACI). Der Trend geht weg von monolithischen Konsolen hin zu verteilten, software-definierten Oberflächen, die sich an den Workflow anpassen, nicht umgekehrt. Für die Zukunft ist entscheidend, dass trotz aller KI und Virtualisierung der Mensch im Mittelpunkt bleibt – mit Schnittstellen, die Stress reduzieren und Kreativität fördern.

#### **Referenzen**

1. DHD AUDIO – Next Generation Radio & TV Live Broadcast Console \- Stagetec Asia, Zugriff am Januar 19, 2026, [https://stagetecasia.com/portfolio/dhd-audio-next-generation-radio-tv-live-broadcast-console/](https://stagetecasia.com/portfolio/dhd-audio-next-generation-radio-tv-live-broadcast-console/)  
2. Mixing Consoles: Networking Allows Better Workflow \- Radio))) ILOVEIT, Zugriff am Januar 19, 2026, [https://radioiloveit.com/radio-production-radio-jingles-radio-imaging/ibc-dhd-audio-radio-broadcast-mixer-audio-over-ip-networks/](https://radioiloveit.com/radio-production-radio-jingles-radio-imaging/ibc-dhd-audio-radio-broadcast-mixer-audio-over-ip-networks/)  
3. RX2 \- DHD.audio, Zugriff am Januar 19, 2026, [https://dhd.audio/products/mixing-consoles/rx2/](https://dhd.audio/products/mixing-consoles/rx2/)  
4. Ruby Radio Mixing Console \- LAWO, Zugriff am Januar 19, 2026, [https://lawo.com/products/ruby/](https://lawo.com/products/ruby/)  
5. diamond \- LAWO, Zugriff am Januar 19, 2026, [https://lawo.com/products/diamond/](https://lawo.com/products/diamond/)  
6. Axia Quasar SR Broadcast Console | Telos Alliance, Zugriff am Januar 19, 2026, [https://www.telosalliance.com/consoles-audio-mixing/broadcast-consoles/axia-quasar-sr](https://www.telosalliance.com/consoles-audio-mixing/broadcast-consoles/axia-quasar-sr)  
7. Axia Quasar™ AoIP Consoles \- Foccus Digital, Zugriff am Januar 19, 2026, [https://www.foccusdigital.com/wp-content/uploads/2025/03/Axia\_Quasar-Family\_Brochure\_C23516100.pdf](https://www.foccusdigital.com/wp-content/uploads/2025/03/Axia_Quasar-Family_Brochure_C23516100.pdf)  
8. GSX \- Wheatstone Corporation, Zugriff am Januar 19, 2026, [https://wheatstone.com/product/gsx/](https://wheatstone.com/product/gsx/)  
9. Wheatstone LXE-3732T, 32 Channel Advanced Modular Networkable Console, with Blade 3 Mix Engine \- Broadcasters General Store, Zugriff am Januar 19, 2026, [https://bgs.cc/wheatstone-lxe-3732t/](https://bgs.cc/wheatstone-lxe-3732t/)  
10. TS-4 & TS-22 \- Wheatstone Corporation, Zugriff am Januar 19, 2026, [https://wheatstone.com/product/talent-stations/](https://wheatstone.com/product/talent-stations/)  
11. Wheatstone TS-22 Talent Station \- Marketing Marc Vallee inc., Zugriff am Januar 19, 2026, [https://www.vallee.com/products/wheatstone-ts-22-talent-station](https://www.vallee.com/products/wheatstone-ts-22-talent-station)  
12. StudioHub SH-ONOFFCOUGH ON/OFF COUGH MUTE, Control Panel, Zugriff am Januar 19, 2026, [https://bgs.cc/studiohub-sh-onoffcough-control-panel/](https://bgs.cc/studiohub-sh-onoffcough-control-panel/)  
13. Guest Gizmo \- Angry Audio, Zugriff am Januar 19, 2026, [https://angryaudio.com/products/guestgizmo/](https://angryaudio.com/products/guestgizmo/)  
14. Modernizing a set of microphone ON/OFF/COUGH button panels : r/broadcastengineering, Zugriff am Januar 19, 2026, [https://www.reddit.com/r/broadcastengineering/comments/1hds5sm/modernizing\_a\_set\_of\_microphone\_onoffcough\_button/](https://www.reddit.com/r/broadcastengineering/comments/1hds5sm/modernizing_a_set_of_microphone_onoffcough_button/)  
15. VisTool MK2 \- Lawo Knowledge Base, Zugriff am Januar 19, 2026, [https://docs.lawo.com/files/100213203/71935265/1/1722251926000/VisTool+MK2+User+Guide+V6.6.0\_5.pdf](https://docs.lawo.com/files/100213203/71935265/1/1722251926000/VisTool+MK2+User+Guide+V6.6.0_5.pdf)  
16. VisTool Virtual Radio Studio Builder \- LAWO, Zugriff am Januar 19, 2026, [https://lawo.com/products/vistool/](https://lawo.com/products/vistool/)  
17. LXE, Glass LXE, and Remote LXE \- Wheatstone Corporation, Zugriff am Januar 19, 2026, [https://wheatstone.com/product/lxe/](https://wheatstone.com/product/lxe/)  
18. Top Four Broadcast Technology Trends: How HMI Solutions Are Shaping the Future of Control Rooms \- Densitron, Zugriff am Januar 19, 2026, [https://www.densitron.com/company/news/Top-four-broadcast-technology-trends-how-hmi-solutions-are-shaping-the-future-of-control-rooms](https://www.densitron.com/company/news/Top-four-broadcast-technology-trends-how-hmi-solutions-are-shaping-the-future-of-control-rooms)  
19. Cartwall | mAirList User Manual, Zugriff am Januar 19, 2026, [https://mairlist.docs.mairlist.com/configuration/cartwall/](https://mairlist.docs.mairlist.com/configuration/cartwall/)  
20. GUI \- mAirList User Manual, Zugriff am Januar 19, 2026, [https://mairlist.docs.mairlist.com/configuration/gui/](https://mairlist.docs.mairlist.com/configuration/gui/)  
21. Zetta: A Walkthrough for New Users \- RCS Sound Software, Zugriff am Januar 19, 2026, [https://www.rcsworks.com/zetta-a-walkthrough-for-new-users/](https://www.rcsworks.com/zetta-a-walkthrough-for-new-users/)  
22. ADVANCED ZETTA CONFIGURATIONS FOR SHARING RADIO CONTENT | RCS Sound Software, Zugriff am Januar 19, 2026, [https://www.rcsworks.com/wp-content/uploads/2023/08/advanced-zetta-configuration\_202308.pdf](https://www.rcsworks.com/wp-content/uploads/2023/08/advanced-zetta-configuration_202308.pdf)  
23. ONAIRTRACKMIXER V1.3 \- LEARN \- DAVID Systems, Zugriff am Januar 19, 2026, [https://learn.davidsystems.com/\_\_attachments/863272968/OnAirTrackMixer\_V1.3\_UserManual.pdf?inst-v=213a39d7-edb5-4570-818e-577caf642785](https://learn.davidsystems.com/__attachments/863272968/OnAirTrackMixer_V1.3_UserManual.pdf?inst-v=213a39d7-edb5-4570-818e-577caf642785)  
24. Loudness | EBU Technology & Innovation, Zugriff am Januar 19, 2026, [https://tech.ebu.ch/loudness](https://tech.ebu.ch/loudness)  
25. Youlean Loudness Meter \- Free VST, AU and AAX plugin, Zugriff am Januar 19, 2026, [https://youlean.co/youlean-loudness-meter/](https://youlean.co/youlean-loudness-meter/)  
26. Yellowtec YT9301 Litt 50/35 Color Segment (Red) \- SCMS Inc., Zugriff am Januar 19, 2026, [https://www.scmsinc.com/yellowtec-yt9301-litt-50-35-color-segment-red.html](https://www.scmsinc.com/yellowtec-yt9301-litt-50-35-color-segment-red.html)  
27. litt \- Yellowtec, Zugriff am Januar 19, 2026, [https://www.yellowtec.com/litt/](https://www.yellowtec.com/litt/)  
28. SmartSign 3 | Broadcast Radio Ltd., Zugriff am Januar 19, 2026, [https://www.broadcastradio.com/smartsign3](https://www.broadcastradio.com/smartsign3)  
29. Screenabl \- Put your studio clock into overdrive, Zugriff am Januar 19, 2026, [https://www.screenabl.com/](https://www.screenabl.com/)  
30. MCO 415 Topic 3 Radio Studio Layout Equipment | PDF | Microphone \- Scribd, Zugriff am Januar 19, 2026, [https://www.scribd.com/document/885347484/MCO-415-Topic-3-Radio-Studio-Layout-Equipment](https://www.scribd.com/document/885347484/MCO-415-Topic-3-Radio-Studio-Layout-Equipment)  
31. How to Layout a Studio Desk for Radio Broadcasting and Podcasting \- Services CloudRadio, Zugriff am Januar 19, 2026, [https://www.cloudrad.io/layout-radio-studio-desk](https://www.cloudrad.io/layout-radio-studio-desk)  
32. Wheatstone GSX-1212 \- Consoles \- Broadcast Supply Worldwide, Zugriff am Januar 19, 2026, [https://bswusa.com/wheatstone-gsx-1212/](https://bswusa.com/wheatstone-gsx-1212/)  
33. Haptics: touch screens come alive in the new HMI design \- Texas Instruments, Zugriff am Januar 19, 2026, [https://www.ti.com/lit/pdf/ssztc56](https://www.ti.com/lit/pdf/ssztc56)  
34. Tactile vs. Touch: Choosing the Right Interface \- Butler Technologies, Zugriff am Januar 19, 2026, [https://butlertechnologies.com/blog/tactile-vs-touch-when-to-use-buttons-or-touch-screen](https://butlertechnologies.com/blog/tactile-vs-touch-when-to-use-buttons-or-touch-screen)  
35. Assessing Subjective Response to Haptic Feedback in Automotive Touchscreens, Zugriff am Januar 19, 2026, [https://www.auto-ui.org/09/docs/p11-Pitts.pdf](https://www.auto-ui.org/09/docs/p11-Pitts.pdf)  
36. YELLOWTEC litt LED SIGNALLING SYSTEM \- Canford Audio, Zugriff am Januar 19, 2026, [https://www.canford.co.uk/YELLOWTEC-litt-LED-SIGNALLING-SYSTEM](https://www.canford.co.uk/YELLOWTEC-litt-LED-SIGNALLING-SYSTEM)  
37. Mix-minus \- Wikipedia, Zugriff am Januar 19, 2026, [https://en.wikipedia.org/wiki/Mix-minus](https://en.wikipedia.org/wiki/Mix-minus)  
38. Proper node configuration for a backfeed (mix-minus) \- Telos Alliance, Zugriff am Januar 19, 2026, [https://docs.telosalliance.com/docs/proper-node-configuration-for-a-backfeed-mix-minus](https://docs.telosalliance.com/docs/proper-node-configuration-for-a-backfeed-mix-minus)  
39. Using Talkback Functions \- DHD.audio, Zugriff am Januar 19, 2026, [https://dhd.audio/dhd-downloads/archive/rm2200d/doc/1\_opserv/html\_eng/ch02s10.html](https://dhd.audio/dhd-downloads/archive/rm2200d/doc/1_opserv/html_eng/ch02s10.html)  
40. diamond \- Monitoring \- Lawo Knowledge Base, Zugriff am Januar 19, 2026, [https://docs.lawo.com/radio-audio-and-broadcast-applications/diamond/diamond-user-manual/diamond-operation/diamond-monitoring](https://docs.lawo.com/radio-audio-and-broadcast-applications/diamond/diamond-user-manual/diamond-operation/diamond-monitoring)  
41. EMBER+ (Pro AV) Client Integration Suite \- Ultamation Shop, Zugriff am Januar 19, 2026, [https://shop.ultamation.com/index.php/product/110-ember-plus-client-suite](https://shop.ultamation.com/index.php/product/110-ember-plus-client-suite)  
42. Seamless Ember+ integration into AVT systems with Lawo mixing consoles \- YouTube, Zugriff am Januar 19, 2026, [https://www.youtube.com/watch?v=iMzUjqKgR6Q](https://www.youtube.com/watch?v=iMzUjqKgR6Q)  
43. Software \- Wheatstone Corporation, Zugriff am Januar 19, 2026, [https://wheatstone.com/product/software/](https://wheatstone.com/product/software/)  
44. How To Set Up Remote Start/Stop LIO Logic for Any Automation System with WheatNet-IP, Zugriff am Januar 19, 2026, [https://support.wheatstone.com/portal/en/kb/articles/how-to-set-up-remote-start-stop-lio-logic-for-any-automation-system-with-wheatnet-ip](https://support.wheatstone.com/portal/en/kb/articles/how-to-set-up-remote-start-stop-lio-logic-for-any-automation-system-with-wheatnet-ip)  
45. multiCAM RADIO Solutions, Zugriff am Januar 19, 2026, [https://www.multicam-systems.com/multicam-radio/](https://www.multicam-systems.com/multicam-radio/)  
46. Multicam RADIO fully automated visual radio \- YouTube, Zugriff am Januar 19, 2026, [https://www.youtube.com/watch?v=00TPQYvMmxA](https://www.youtube.com/watch?v=00TPQYvMmxA)  
47. YOU'RE LOOKING GOOD OUT THERE \- Wheatstone Corporation, Zugriff am Januar 19, 2026, [https://wheatstone.com/wheat-news/youre-looking-good-out-there/](https://wheatstone.com/wheat-news/youre-looking-good-out-there/)  
48. Bionic Social \- Broadcast Bionics, Zugriff am Januar 19, 2026, [https://www.bionics.co.uk/socialmediasystems.cshtml](https://www.bionics.co.uk/socialmediasystems.cshtml)  
49. Bionic Social \- AVC Group, Zugriff am Januar 19, 2026, [https://www.avc-group.net/Products/bionic-social](https://www.avc-group.net/Products/bionic-social)  
50. Playout automation | Rohde & Schwarz, Zugriff am Januar 19, 2026, [https://www.rohde-schwarz.com/cz/products/broadcast-and-media/playout-automation\_255728.html](https://www.rohde-schwarz.com/cz/products/broadcast-and-media/playout-automation_255728.html)  
51. Playout X | Cloud-Native Channel Playout \- Grass Valley, Zugriff am Januar 19, 2026, [https://www.grassvalley.com/products/ampp/playout-x/](https://www.grassvalley.com/products/ampp/playout-x/)  
52. The Next-Generation Radio Studio: Concept Design \- RadioInfo Australia, Zugriff am Januar 19, 2026, [https://radioinfo.com.au/audioinfo/concept-design-for-the-next-generation-radio-studio-2026-and-beyond/](https://radioinfo.com.au/audioinfo/concept-design-for-the-next-generation-radio-studio-2026-and-beyond/)  
53. Broadcast Bionics Voice GPIO Brings AI Control to Talkback Systems | IBC2025 \- YouTube, Zugriff am Januar 19, 2026, [https://www.youtube.com/watch?v=lLOVeVlKgoA](https://www.youtube.com/watch?v=lLOVeVlKgoA)  
54. Scenarios for AI and radio in 2030 revisited \- RedTech, Zugriff am Januar 19, 2026, [https://www.redtech.pro/scenarios-for-ai-and-radio-in-2030-revisited/](https://www.redtech.pro/scenarios-for-ai-and-radio-in-2030-revisited/)  
55. Making Touchscreens live up to their name: touch feedback as the essential element to… | by Steven D. Domenikos | Medium, Zugriff am Januar 19, 2026, [https://medium.com/@sdomenikos/making-touchscreens-live-up-to-their-name-touch-feedback-as-the-essential-element-to-b67def73d200](https://medium.com/@sdomenikos/making-touchscreens-live-up-to-their-name-touch-feedback-as-the-essential-element-to-b67def73d200)  
56. Toolbox 4 Configuration Reference \- DHD.audio, Zugriff am Januar 19, 2026, [https://dhd.audio/dhd-downloads/archive/dhd\_files/doc/3\_conf/html\_en/ch08.html](https://dhd.audio/dhd-downloads/archive/dhd_files/doc/3_conf/html_en/ch08.html)  
57. Logic Flows \- Telos Alliance, Zugriff am Januar 19, 2026, [https://docs.telosalliance.com/docs/v19-logic-flows](https://docs.telosalliance.com/docs/v19-logic-flows)