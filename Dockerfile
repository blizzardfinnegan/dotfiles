#WARNING: Missing packages: cgdb, tmux.
# tmux might be installed on the "hypervisor"; neovim as alternative, see :terminal. cgdb is outdated, use gdb -tui
ARG CONTAINER_NAME
ARG CONTAINER_VERSION
FROM ${CONTAINER_NAME}:v${CONTAINER_VERSION}
ARG NEOVIM_VERSION=0.12.2
ARG TREE_SITTER_VERSION=0.26.9
WORKDIR /home/bfinnegan
ENV HOME=/home/bfinnegan

# Build and install neovim
RUN wget https://github.com/neovim/neovim/archive/refs/tags/v${NEOVIM_VERSION}.zip && \
	unzip v${NEOVIM_VERSION}.zip && pushd neovim-${NEOVIM_VERSION} && \
	make CMAKE_BUILD_TYPE=Release && make install && \
	popd && rm -rf neovim-${NEOVIM_VERSION} v${NEOVIM_VERSION}.zip

# TODO: Install tree-sitter
RUN wget https://github.com/tree-sitter/tree-sitter/archive/refs/tags/v${TREE_SITTER_VERSION}.zip && \
	unzip v${TREE_SITTER_VERSION}.zip && pushd tree-sitter-${TREE_SITTER_VERSION} && \
	cargo install --locked tree-sitter-cli && \
	popd && rm -rf tree-sitter-${TREE_SITTER_VERSION} v${TREE_SITTER_VERSION}.zip

# Install LSPs; clangd and rust-analyzer are expected to already be installed
RUN pip install pyright 

ARG LD_LIBRARY_PATH=/opt/rh/gcc-toolset-13/root:/opt/intel/oneapi/tbb/latest/lib/intel64/gcc4.8:/usr/local/lib64:

RUN mkdir -p ~/.config/nvim/pack/bundle/start && \
	cd ~/.config/nvim/pack/bundle/start && \
 	git clone https://github.com/lewis6991/gitsigns.nvim && \
 	git clone https://github.com/romus204/tree-sitter-manager.nvim && \
 	git clone https://github.com/neovim/nvim-lspconfig && \
 	git clone https://github.com/hrsh7th/cmp-nvim-lsp && \
 	git clone https://github.com/hrsh7th/nvim-cmp && \
 	git clone https://github.com/nvim-lualine/lualine.nvim && \
 	git clone https://github.com/lukas-reineke/indent-blankline.nvim && \
 	git clone https://github.com/tpope/vim-sleuth && \
 	git clone https://github.com/folke/which-key.nvim && \
 	git clone https://github.com/nvim-tree/nvim-web-devicons && \
 	git clone https://github.com/nvim-tree/nvim-tree.lua

# Download dotfiles
RUN git clone -b airgap https://github.com/blizzardfinnegan/dotfiles && \
	 cp -r dotfiles/nvim ~/.config/.  && \
	 echo "LANG=en_IE.utf8" > /etc/locale.conf && \
	 ln -sf /usr/share/zoneinfo/America/Denver /etc/localtime
