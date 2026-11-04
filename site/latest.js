// The latest release, for the update page (/update/). Edit on every release: version + what's new.
// Notes: Ukrainian and English; other languages show the English notes.
const LATEST = {
  version: "0.9.3",
  notes: {
    uk: ["Безпечніше оновлення: Windows перевіряє підпис файлу версії й завантажує лише з релізів AURA на GitHub; Mac не поставить старішу версію замість нової.",
         "Windows: під час завантаження оновлення меню й іконка більше не зависають.",
         "Імена й назви, набрані з малої літери, теж виправляються: «вынницею» → «вінницею».",
         "Mac: подвійний ⇧ на новому слові завжди починає з найімовірнішої мови.",
         "Якщо у вас 0.9 або новіша — «Перевірити оновлення» → «Оновити»."],
    en: ["Safer updates: Windows checks the signature of the version file and downloads only from AURA's GitHub releases; Mac won't install an older version over a newer one.",
         "Windows: the menu and the tray icon no longer freeze while an update downloads.",
         "Names typed in lower case are fixed too: «вынницею» → «вінницею».",
         "Mac: double ⇧ on a new word always starts with the most likely language.",
         "On 0.9 or newer: «Check for updates» → «Update»."],
  },
};
