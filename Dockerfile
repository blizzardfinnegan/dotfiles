FROM artifactory.scitec.com/mdpap/base-images/tier-1l/app-builder:v1.2.0 AS builder

WORKDIR /root
RUN dnf -y install rpm-build rpmdevtools && \
	git clone -b airgap https://github.com/blizzardfinnegan/dotfiles && \
	rpmdev-setuptree && \
	wget -O - https://github.com/neovim/neovim/archive/refs/tags/v0.11.1.zip > /root/rpmbuild/SOURCES/v0.11.1.zip && \
	rpmbuild -bb ./dotfiles/neovim.spec && \
	mv /root/rpmbuild/RPMS/x86_64/neovim-0.11.1-1.el8.x86_64.rpm /.


FROM artifactory.scitec.com/mdpap/base-images/tier-1l/app-builder:v1.2.0 


# nvim latest (might need a builder container first for final container size)
WORKDIR /root 
RUN git clone https://github.com/neovim/neovim && \
	cd neovim && git checkout stable && \
	make CMAKE_BUILD_TYPE=Release && make install && \
	cd .. && rm -rf neovim

# DNF installs: tmux, graphviz, cgdb
COPY --from=builder /neovim-0.11.1-1.el8.x86_64.rpm .
# 	Umbrello fails because of ninja conflicts; mermaid is it's own container
RUN dnf -y install tmux graphviz cgdb tree npm lua luajit rpm-build rpmdevtools fish ripgrep gnuplot ImageMagick ghostscript && \
	dnf -y --nogpgcheck install gcc13
# Wont-fix: GPG fails because it's a handmade RPM that doesn't have a valid GPG key built into it (I think?)
RUN dnf -y --nogpgcheck install ./neovim-0.11.1-1.el8.x86_64.rpm && rm ./neovim-0.11.1-1.el8.x86_64.rpm

# Install LSPs; clangd is already installed
RUN pip install pyright && \ 
	rustup component add rust-analyzer && \
	npm i -g vscode-json-languageservice && \
	npm i -g yaml-language-server

ARG LD_LIBRARY_PATH=/opt/rh/gcc-toolset-13/root:/opt/intel/oneapi/tbb/latest/lib/intel64/gcc4.8:/usr/local/lib64:
# Install neovim packages manually
# RUN mkdir -p ~/.local/share/nvim/site/pack && cd ~/.local/share/nvim/site/pack && \
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
	 usermod --shell /usr/bin/fish root && \
	 echo "LANG=en_IE.utf8" > /etc/locale.conf && \
	 ln -sf /usr/share/zoneinfo/America/Denver /etc/localtime && \
	 cp dotfiles/.gitconfig ~/.
RUN rm latest_commit
