FROM artifactory.scitec.com/mdpap/base-images/tier-1l/app-builder-9:v1.0.0 AS builder

#WARNING: Missing packages: cgdb, fish, tmux.
# tmux might be installed on the "hypervisor"... cgdb is outdated, use gdb -tui
# Fish can be compiled and manually installed

WORKDIR /root
#RUN dnf -y install rpm-build rpmdevtools && \
#	git clone -b airgap https://github.com/blizzardfinnegan/dotfiles && \
#	rpmdev-setuptree && \
#	wget -O - https://github.com/neovim/neovim/archive/refs/tags/v0.11.1.zip > /root/rpmbuild/SOURCES/v0.11.1.zip && \
#	rpmbuild -bb ./dotfiles/neovim.spec && \
#	mv /root/rpmbuild/RPMS/x86_64/neovim-0.11.1-1.el9.x86_64.rpm /.


FROM artifactory.scitec.com/mdpap/base-images/tier-1l/app-builder-9:v1.0.0 


# nvim latest (might need a builder container first for final container size)
WORKDIR /root 

# Build and install neovim
RUN wget https://github.com/neovim/neovim/archive/refs/tags/v0.11.2.zip && \
	unzip v0.11.2.zip && cd neovim-0.11.2 && \
	make CMAKE_BUILD_TYPE=Release && make install && \
	cd .. && rm -rf neovim-0.11.2 v0.11.2.zip

ENV FISH_BUILD_VERSION=4.0.2
RUN wget https://github.com/fish-shell/fish-shell/archive/refs/tags/4.0.2.zip && \
	unzip 4.0.2.zip && cd fish-shell-4.0.2 && \
	mkdir build && cd build && \
	cmake .. && cmake --build . && \
	cmake --install . && \
	cd ../.. && rm -rf 4.0.2.zip fish-shell-4.0.2


# Install LSPs; clangd and rust-analyzer is already installed
RUN pip install pyright 
	#npm i -g vscode-json-languageservice && \
	#npm i -g yaml-language-server

ARG LD_LIBRARY_PATH=/opt/rh/gcc-toolset-13/root:/opt/intel/oneapi/tbb/latest/lib/intel64/gcc4.8:/usr/local/lib64:

RUN mkdir -p ~/.config/nvim/pack/bundle/start && \
	mkdir -p ~/.config/nvim/pack/bundle/opt && \
	cd ~/.config/nvim/pack/bundle/start && \
 	git clone https://github.com/nvim-lua/plenary.nvim && \
 	git clone https://github.com/lewis6991/gitsigns.nvim && \
 	git clone https://github.com/numToStr/Comment.nvim && \
 	git clone https://github.com/nvim-treesitter/nvim-treesitter && \
 	git clone https://github.com/neovim/nvim-lspconfig && \
 	git clone https://github.com/hrsh7th/cmp-nvim-lsp && \
 	git clone https://github.com/hrsh7th/nvim-cmp && \
 	git clone https://github.com/nvim-lualine/lualine.nvim && \
 	git clone https://github.com/lukas-reineke/indent-blankline.nvim && \
 	git clone https://github.com/tpope/vim-sleuth && \
 	git clone https://github.com/folke/which-key.nvim && \
 	git clone https://github.com/nvim-tree/nvim-web-devicons && \
 	git clone https://github.com/nvim-tree/nvim-tree.lua && \
	cd ~/.config/nvim/pack/bundle/opt && \
 	git clone https://github.com/lervag/vimtex

# Install TreeSitter headers for inline highlighting for various languages
RUN mkdir -p ~/.local/share/nvim/site/parser && cd ~/.local/share/nvim/site/parser && \
	nvim --headless "+TSInstall c cpp dot go diff git_config git_rebase gitcommit gitignore java make properties proto regex tmux tsv xresources comment lua python rust typescript csv ini jinja jinja_inline json cmake toml xml yaml" "+sleep 30" +qa


# Download dotfiles
ADD "https://api.github.com/repos/blizzardfinnegan/dotfiles/commits?sha=airgap&per_page=1" latest_commit
RUN git clone -b airgap https://github.com/blizzardfinnegan/dotfiles && \
	 cp -r dotfiles/nvim ~/.config/.  && \
	 cp -r dotfiles/fish ~/.config/. && \
	 cp -r dotfiles/.tmux.conf ~/. && \
	 usermod --shell /usr/local/bin/fish root && \
	 echo "LANG=en_IE.utf8" > /etc/locale.conf && \
	 ln -sf /usr/share/zoneinfo/America/Denver /etc/localtime && \
	 cp dotfiles/.gitconfig ~/.
RUN rm latest_commit
