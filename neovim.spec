Name:           neovim
Version:        0.11.1
Release:        1%{?dist}
Summary:        Neovim text editor

License:        Apache
Source:         https://github.com/neovim/neovim/archive/refs/tags/v0.11.1.zip

BuildRequires: libtool
BuildRequires: autoconf
BuildRequires: automake
BuildRequires: gcc-c++
BuildRequires: pkgconfig
BuildRequires: patch
BuildRequires: gettext
BuildRequires: ninja-build 
BuildRequires: cmake
BuildRequires: gcc 
BuildRequires: make 
BuildRequires: unzip 
BuildRequires: gettext 
BuildRequires: curl

%description
Neovim, Vim-fork focused on extensibility and usability


%prep
%autosetup


%build
make CMAKE_BUILD_TYPE=Release


%install
%make_install


%files
%defattr(-,root,root)
/usr/local/bin/nvim
/usr/local/share
/usr/local/lib64/nvim
/usr//lib/debug/usr/local/lib64/nvim

