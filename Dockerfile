#WARNING: Missing packages: cgdb, tmux.
# tmux might be installed on the "hypervisor"; neovim as alternative, see :terminal. cgdb is outdated, use gdb -tui
ARG CONTAINER_VERSION=1.1.1
FROM artifactory.scitec.com/mdpap/base-images/tier-1l/app-builder-9:v${CONTAINER_VERSION}
ARG NEOVIM_VERSION=0.11.4
ARG FISH_BUILD_VERSION=4.0.2
WORKDIR /home/bfinnegan
ENV HOME=/home/bfinnegan

# Build and install neovim
RUN wget https://github.com/neovim/neovim/archive/refs/tags/v${NEOVIM_VERSION}.zip && \
	unzip v${NEOVIM_VERSION}.zip && pushd neovim-${NEOVIM_VERSION} && \
	make CMAKE_BUILD_TYPE=Release && make install && \
	popd && rm -rf neovim-${NEOVIM_VERSION} v${NEOVIM_VERSION}.zip

# Fish can be compiled and manually installed
RUN wget https://github.com/fish-shell/fish-shell/archive/refs/tags/${FISH_BUILD_VERSION}.zip && \
	unzip ${FISH_BUILD_VERSION}.zip && pushd fish-shell-${FISH_BUILD_VERSION} && \
	mkdir build && pushd build && \
	cmake .. && cmake --build . && \
	cmake --install . && \
	popd && popd && rm -rf ${FISH_BUILD_VERSION}.zip fish-shell-${FISH_BUILD_VERSION}


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
RUN git clone -b airgap https://github.com/blizzardfinnegan/dotfiles && \
	 cp -r dotfiles/nvim ~/.config/.  && \
	 cp -r dotfiles/fish ~/.config/. && \
	 cp -r dotfiles/.tmux.conf ~/. && \
	 usermod --shell /usr/local/bin/fish root && \
	 echo "LANG=en_IE.utf8" > /etc/locale.conf && \
	 ln -sf /usr/share/zoneinfo/America/Denver /etc/localtime && \
	 cp dotfiles/.gitconfig ~/.
