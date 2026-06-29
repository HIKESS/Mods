name = "Tradução Brasileira"
author = "HowlingBreeze"
version = "8.3.0"
description =
[[Este mod funciona melhor em servidores com cavernas ou hospedados por outras pessoas.

Últimas Mudanças:
• Renomeados alguns itens, criaturas, e algumas abas de criação.
• Revisão de mais algumas falas da Wurt e de alguns itens da Coleção de Itens, biografias do Compêndio e opções.
• Melhorias para os nomes exibidos pela opção "Nomes Originais".
• Otimizações e correções para a tradução de telas.
• Várias correções.

(Veja a lista em detalhes na página do mod.)]]

--[[
[v.8.3.0]
Mudanças na Tradução:
• Atualização Confronto Afrontoso totalmente traduzida.
• Renomeados alguns nomes de itens e criaturas:
	- Cervoclope -> Cerviclope
	- Piso Vermelho Mosaico -> Piso Mosaico Vermelho (para combinar com os demais pisos mosaicos)
	- Solo de Pedra -> Solo Rochoso
	- Piso de Fumarola das Cavernas -> Solo de Fumarola das Cavernas
	- Foco de Telelocador -> Foco Telelocador
	- Lula-Deslizate/Luleslizante -> Escapulula
• Renomeadas algumas abas de criação.
	- Equipamento para Bífalo -> Montaria de Bífalo
	- Armadura -> Armaduras
	- Navegação -> Navegação Marítima
	- Pescaria -> Pesca
• Revisão de mais algumas falas da Wurt.
	- Mais especificamente: as falas de anúncio e falha ao realizar uma ação.
• Revisão de alguns itens da Coleção de Itens, biografias do Compêndio e descrições de opções.
	- A linha "Os Desertados" de visuais foi renomada para "Os Desbravadores".

Mudanças Técnicas:
• A detecção de entidades nomeadas por jogadores agora é automática em vez de depender de exclusões manuais.
• A opção "Nomes Originais" agora é mais flexível para nomes dinâmicos.
• Agora Projetos, Rascunhos, Cartões de Receita, etc, têm seus nomes apropriadamente exibidos quando não estiver jogando como cliente.
	- Eles agora também têm suporte para a opção "Nomes Originais".
• Otimização e correções para a tradução de telas.
	- A tradução de tela agora age somente sobre elementos específicos, tornando-a mais otimizada.
	- Em decorrência disso, textos não saltam mais de lugar em certas telas.
• Renomeadas as opções da categoria "Nomes".
	- As opções não têm mais "Nomes" escrito antes delas.
	- A opção "Diversos" foi mudada para "Formatados" para representar melhor o que a opção afeta.
• As opções "Livro de Receitas" e "Árvores de Habilidades" foram mescladas com a opção "Interface" (anteriormente "Menus").
• Reformulação e otimização do código de carregamento de traduções e atribuição de gênero.
	- Isso afeta pouquíssimo a experiência do usuário, mas me fornece ferramentas de tradução poderosas que serão utilizadas no futuro.

Correções:
• Corrigido o Nutrijolo usar "Umedecida" como seu adjetivo de estar molhado.
• Corrigido o nome do Altar Perene aparecer em inglês nas mensagens de ressurreição.
• Corrigido verbos de ação sempre incluírem o nome do item ao passar o mouse em cima deles, mesmo quando não deviam.
• Corrigido nomes com hífen não sofrerem todas as alterações de tradução quando o mouse é passado sobre eles.
• Corrigido os nomes na lista de Causas Comuns de Morte e Obituários terem letras maiúsculas após acentos.
• Corrigido receitas no Livro de Receitas do Compêndio não terem seus status exibidos.
• Corrigido os nomes de jogadores poderem ser traduzidos no nome do Altar Perene e em anúncios de chat.
]]

api_version = 10
priority = -2000

dst_compatible = true
all_clients_require_mod = false	
client_only_mod = true
server_filter_tags = { "br" }

icon_atlas = "modicon.xml"
icon = "modicon.tex"

forumthread = ""

local function MakeHeader(title)
	return { name = "", label = title, options = { {description = "", data = 0}, }, default = 0, }
end

local function MakeSeparator()
	return {
        name = "",
        label = "---------------------------------------",
        options =
		{
			{description = "------------", data = false},
		},
		default = false,
    }
end

local options =
{
	toggle =
	{
		{description = "Sim", data = true},
		{description = "Não", data = false},
	},
	
	toggle_inverse =
	{
		{description = "Sim", data = false},
		{description = "Não", data = true},
	},

	switch =
	{
		{description = "Habilitado", data = true},
		{description = "Desabilitado", data = false},
	},
}

configuration_options =	
{	
	MakeHeader("Geral"),
	{
		name = "TOGGLE_SPEECH",
		label = "Diálogo de Personagem",
		hover = "Traduz as falas ditas pelos personagens no mundo quando jogar como cliente.",
        options = options.switch,
        default = true,
	},
	{
		name = "TOGGLE_ANNOUNCEMENTS",
		label = "Mensagens do Jogo",
		hover = "Traduz as mensagens do jogo, como de ressurreição e morte, quando jogar como cliente.",
        options = options.switch,
        default = true,
	},
	{
		name = "TOGGLE_SCREENS",
		label = "Interface",
		hover = "Traduz certos textos da interface que não podem ser traduzidos normalmente.",
        options = options.switch,
        default = true,
	},
	
	MakeHeader("Nomes"),
	{
		name = "TOGGLE_BOSSES",
		label = "Chefes",
		hover = "Quando habilitada, os nomes dos chefões serão traduzidos.\nIsso inclui tudo o que o jogo considera internamente como um \"chefe\".",
        options = options.toggle_inverse,
        default = false,
	},
	{
		name = "TOGGLE_BLUEPRINTS",
		label = "Formatados",
		hover = "Quando habilitada, traduz os nomes de itens cujo nome varia com base em certos fatores, como Projetos e Rascunhos.",
        options = options.toggle,
        default = true,
	},
	{
		name = "TOGGLE_NAMED",
		label = "Próprios",
		hover = "Quando habilitada, traduz os nomes próprios dados a criaturas como Porcomens e Coelhomens.\nExclui nomes dados por jogadores.",
        options = options.toggle,
        default = true,
	},
	{
		name = "TOGGLE_NOTBOSSES",
		label = "Outros",
		hover = "Quando habilitada, traduz os nomes de tudo não listado acima.",
        options = options.toggle_inverse,
        default = false,
	},
	
	MakeHeader("Extras"),
	{
		name = "TOGGLE_ORIGINAL",
		label = "Nomes Originais",
		hover = "Exibe os nomes originais das coisas ao lado do nome traduzido, entre parenteses. Útil caso queira pesquisar na Wiki ou se familiarizar.",
        options = options.switch,
        default = false,
	},
	--MakeSeparator(),
	{
		name = "PREFS_ORIGINAL_LINEBREAK",
		label = "Quebra de Linha",
		hover = "Quando habilitada, os nomes originais dos itens aparecem abaixo do traduzido, em vez de ao lado.",
        options = options.toggle,
        default = false,
	},
	
	MakeHeader("Versão do Mod [v."..version.."]"),
}