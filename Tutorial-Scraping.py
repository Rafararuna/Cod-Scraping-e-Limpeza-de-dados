#%%
import bs4
import cloudscraper #faz a requisição pra receber os dados da pagina
from bs4 import BeautifulSoup #faz o tratamento do texto e extração por css
import re #para expressoes regulares


#%%

### ACESSAR PAGINA
"""
    Essa biblioteca cloudscraper é específica para tratar o acesso restringido
por tecnologias anti-bot do cloudflare. Ele não passa do recaptcha, mas pela
maneira que o Wimoveis executa a ação anti-bot, ele previne que sequer seja
necessário passar pelo recaptcha. Caso isso mude, vai ser necessário utilizar o
Selenium pra fazer a coleta acontecer, para que o captcha seja respondido 
manualmente e o restante da coleta rode individualmente.
"""

scraper = cloudscraper.create_scraper()
content = scraper.get('https://www.google.com').text  # acessar url e pegar seu texto (HTML)
# .content é equivalente ao .text para extrair a resposta em HTML do servidor
content = scraper.get(
    'https://www.wimoveis.com.br/propriedades/apartamento-no-noroeste-brasilia-vogue-2948160963.html').text
#%%
### TRATANDO RESPOSTA DA PAGINA
"""
    O rvest do R é especial e faz algumas coisas mais mastigadas pra gente, mas
em praticamente todas as linguagens as operações são um pouco mais manuais.

    Nesse caso, o pacote do scraper apenas faz a requisição para o servidor e
extrai seu texto, mas o BeautifulSoup que cuida das buscas e tratamentos em si 
que fazemos no HTML. Ele tem esse nome por brincar de chamar as strings enormes 
como uma sopa de letras (soup), e bonita (beautiful) porque ele organiza a sopa.

    Aqui vou mostrar pra vocês as principais funções básicas de scraping que são
necessárias em geral.

Documentação BeatifulSoup: https://www.crummy.com/software/BeautifulSoup/bs4/doc/
"""

soup = BeautifulSoup(content, 'html.parser')
soup
#%%
# Para extrair os elementos da pagina segundo especifações (caso geral/exemplo):
soup.find_all('tag', class_='classe', id='id', 
              attrs={'nome_atributo': 'valor_atributo'})
#%%
soup.find_all('h2', class_='title-type-sup')

#%%
soup.select('seletor css') # seleciona tudo que atende ao seletor css
soup.select('h2.title-type-sup')
#%%
soup.find('h2', class_='title-type-sup') # primeira ocorrencia
soup.select_one('seletor css') # seleciona primeiro caso que atende ao css
#%%
a=soup.select_one('#article-container > section.article-section.article-section-description > div.section-title > h1')
a.string
#%%

um_elemento = soup.select('#article-container > section.article-section.article-section-description > div.section-title > h1')[0]
um_elemento
#%%
um_elemento = soup.select('h2.title-type-sup')[0] # um elemento qualquer da pagina
# encontrar a proxima ocorrencia de um elemento que atende às especificaçoes
# e que seja posterior ao elemento em questao
um_elemento.find_next('tag', class_='classe', id='id', #mesma sintaxe do find_all
                      attrs={'nome_atributo': 'valor_atributo'}) 

# na mesma ideia do find_next, existe o find_previous só que pra elementos 
# anteriores ao elemento em questao
um_elemento.find_previous()

um_elemento.string # extrair o texto dentro de um elemento/tag
um_elemento.attrs # extrair os atributos de um elemento/tag em forma de dicionario
#%%
### REGEX

""" 
    Em python, existem strings especiais que são exclusivas para o uso de regex,
assim como a maioria das linguagens (R é exceção). Pra você definir que uma
string é de expressão regular (e evitar ter que usar \\ ao invés de só um \), 
basta colocar um r antes: r'uma string'.

    As funções do python para executar as ações em regex são fornecidas pelo
pacote re, que vem por padrão no python. Em geral, as funções seguem dois
possíveis padrões:

    -> re.funcao(r'padrao da regex', 'a string que quer ser analisada em questao'):
semelhante ao rvest mas na ordem contraria, já que no rvest informamos primeiro 
a string e depois o padrão de regex;

    -> re.compile(r'padrao da regex'): seria como já deixar esse padrão preparado
(compilado) para ser aplicado de forma especifica em uma string, dependendo do
método a ser utilizado. Basta reservar esse padrão compilado numa variável e
então usar algum método específico com essa nova variável.

    A sintaxe e metacaracteres das expressões são identicas às do R, com um
adicional que você pode nomear os grupos que normalmente você só se referenciaria
com \\1, \\2, etc. Exemplo de referencias de grupos nomeados e não nomeados:
    - r'(padrao 1) (padrao 2)' → \\1, \\2
    - r'(?P<nome1>padrao 1) (?P<batata>padrao 2)' → \\nome1, \\batata
e isso possui uma vantagem: nomeando os grupos, você pode extrair um dicionário
diretamente do nome do grupo e o valor que deu match ao padrao, por exemplo 
nesse caso ele retornaria:    {'nome1': 'padrao 1', 'batata': 'padrao 2'}

    Atenção ao fato que você não pode passar um vetor de strings, somente uma
string a ser procurada o padrão.

    Substituam os valores para vocês treinarem os códigos (alguns não vão rodar
sem alterações)

Documentação re: https://docs.python.org/3/library/re.html
"""
# usaremos como exemplo o texto extraído pelo scraping acima
texto = um_elemento.string

# EXEMPLOS PARA O PRIMEIRO CASO (não pré-compilado)
re.search(r'padrao da regex', 'string') #seria mais proximo do str_extract, retorna
# um objeto Match que possui métodos, como:
# -> pra extrair todos os matchs:
re.search(r'padrao da regex', 'string')[0] 
# -> pra extrair um grupo pelo index:
re.search(r'padrao da (regex)', 'string')[1] 
# -> pra extrair um grupo pelo nome do grupo:
re.search(r'padrao da (?<oisdds>regex)', 'string')['oisdds']
# -> pra extrair um dicionario com os grupos:
re.search(r'padrao da (?<oisdds>regex)', 'string').groupdict()
re.findall(r'padrao da regex', 'string') #seria mais proximo do str_extract_all
"""
se no findall você tiver vários grupos, ele vai retornar uma tupla com o match
encontrado pra cada grupo dentro de um vetor (caso haja mais de uma ocorrencia
de match para o padrao no total)
"""

re.sub(r'padrao da regex', 'substituto do padrao', 'string', count=4) 
"""
equivale str_replace_all, count é um parametro para limitar quantas substituiçoes
no maximo podem ser feitas. não é obrigatório, se não for definido ele substitui
todas as ocorrências
"""

re.split(r'padrao da regex', 'string') #equivale str_split

# EXEMPLOS PARA O SEGUNDO CASO (não pré-compilado)
"""
    Segue literalmente a mesma ideia, mas ao invés de você definir o primeiro
parâmetro do padrão, a sua variável já vai ter o padrão definido, então se usa os
mesmos métodos para continuar a preencher os próximos argumentos.
"""

padrao_1 = re.compile(r'padrao da regex')

# eu vou literalmente copiar e colar fazendo as modificações para ser paralelo
padrao_1.search('string') #seria mais proximo do str_extract, retorna
# um objeto Match que possui métodos, como:
# -> pra extrair todos os matchs:
padrao_1.search('string')[0] 
# -> pra extrair um grupo pelo index:
padrao_1.search('string')[1] 
# -> pra extrair um grupo pelo nome do grupo:
padrao_1.search('string')['oisdds']
# -> pra extrair um dicionario com os grupos:
padrao_1.search('string').groupdict()
padrao_1.findall('string') #seria mais proximo do str_extract_all
"""
se no findall você tiver vários grupos, ele vai retornar uma tupla com o match
encontrado pra cada grupo dentro de um vetor (caso haja mais de uma ocorrencia
de match para o padrao no total)
"""

padrao_1.sub('substituto do padrao', 'string', count=4) 
"""
equivale str_replace_all, count é um parametro para limitar quantas substituiçoes
no maximo podem ser feitas. não é obrigatório, se não for definido ele substitui
tudas as ocorrências
"""

padrao_1.split('string') #equivale str_split
# %%
