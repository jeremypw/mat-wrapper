project(
    'com.github.jeremypw.mat-wrapper', 'vala', 'c',
    meson_version : '>= 0.43',
    version: '1.0.0'
)

i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="com.github.jeremypw.mat-wrapper"', language:'c')

vala = meson.get_compiler('vala')
posix_dep = vala.find_library('posix')

core_deps = [
    posix_dep,
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('granite')
]

subdir('data')
subdir('po')
subdir('src')
