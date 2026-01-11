# Maintainer: Mikhail Nazarov <mikhail.a.nazarov@yandex.ru>
pkgname=geary-custom
pkgver=46.0
pkgrel=1
pkgdesc="Geary email client with avatar icons, tray icon and improved styling"
arch=('x86_64')
url="https://github.com/MikhailNazarov/geary-custom"
license=('LGPL-2.1-or-later')
depends=(
  'cairo'
  'enchant'
  'folks'
  'gcr-4'
  'glib2'
  'gspell'
  'gtk3'
  'hicolor-icon-theme'
  'icu'
  'iso-codes'
  'json-glib'
  'libappindicator-gtk3'
  'libhandy'
  'libpeas'
  'libsecret'
  'libsoup3'
  'libstemmer'
  'libytnef'
  'org.freedesktop.secrets'
  'sqlite'
  'webkit2gtk-4.1'
)
makedepends=(
  'appstream-glib'
  'cmake'
  'git'
  'gobject-introspection'
  'meson'
  'vala'
  'yelp-tools'
)
optdepends=('gnome-online-accounts: GNOME Online Accounts support')
provides=('geary')
conflicts=('geary')
options=('!emptydirs')
source=()

build() {
  cd "$startdir"
  arch-meson build \
    -Dprofile=release
  meson compile -C build
}

package() {
  cd "$startdir"
  meson install -C build --destdir "$pkgdir"
}
