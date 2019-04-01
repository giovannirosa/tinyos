# TCC

Trabalho de Conclusão de Curso - Ciência da Computação - UFPR.

## Conteúdo

Nesse repositório é possível encontrar experimentos realizados com TinyOS e seu simulador TOSSIM. Também foi utilizada uma ferramenta gráfica limitada: JTossim.

## Início

Existe um makefile em cada diretório com os seguintes comandos disponíveis:

* make micaz sim: compila os arquivos para simulação no TOSSIM.
* make clean: limpa os arquivos gerados para simulação.

### Pré-requisitos

É necessario ter o TinyOS 2.1.2 instalado. São diversas dependências específicas, é possível encontrar um relatório de instalação do TinyOS nesse repositório.

## Testando

É possível testar os programas utilizando o TOSSIM. Através de um script em python e com a adição de linhas com dbg() para saída padrão stdout, conseguimos simular os eventos e monitorar o comportamento dos programas.

## Bibliotecas Utilizadas

* [TinyOS](http://tinyos.stanford.edu/tinyos-wiki/index.php/Installing_TinyOS) - TinyOS is an "operating system" designed for low-power wireless embedded systems

## Autor

* **Giovanni Rosa** - [giovannirosa](https://github.com/giovannirosa)

## Licença

Código aberto, qualquer um pode usar para qualquer propósito.
