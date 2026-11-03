// The latest release, for the update page (/update/). Edit on every release: version + what's new.
// Notes: Ukrainian and English; other languages show the English notes.
const LATEST = {
  version: "0.9.2",
  notes: {
    uk: ["Mac: російська розкладка знову працює зі словником macOS — слова на кшталт «зашёл» («pfi`k») виправляються. Раніше словник помилково вимикався.",
         "Із 0.9.1: виправлення обирає найнадійніший варіант (з розкладками RU, UK, EN «ghbdsn» → «привіт»), подвійний ⇧ спершу йде в найімовірнішу мову.",
         "Якщо у вас 0.9 або новіша — «Перевірити оновлення» → «Оновити»."],
    en: ["Mac: the Russian layout works with the macOS dictionary again — words like «зашёл» («pfi`k») are fixed. The dictionary used to be switched off by mistake.",
         "From 0.9.1: correction picks the most reliable option (with RU, UK, EN «ghbdsn» → «привіт»), double ⇧ goes to the most likely language first.",
         "On 0.9 or newer: «Check for updates» → «Update»."],
  },
};
