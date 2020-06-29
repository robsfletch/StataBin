{smcl}
{* *! version 1.2.2  15may2018}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Title}

{phang}
{bf:DHS} {hline 2} Generate the DHS percentage difference between two variables


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:DHS}
[{varlist}]
[{if}]
[{in}]
{cmd:,}
{it:gen:erate(numlist)}
[{it:zeros}]
[{it:one}]
[{it:replace}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt gen:erate}} the name of the variable to save the DHS measure in {p_end}
{synopt:{opt zeros}} Include 0 to 0 changes as 0 {p_end}
{synopt:{opt one}} use a scale of -1 to 1 instead of -2 to 2 {p_end}
{synopt:{opt replace}} replace the original variable being generated {p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:DHS} Generate the DHS percentage difference between two variables


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt generate} the name of the variable to save the DHS measure in 

{phang}
{opt zeros} Include 0 to 0 changes as 0

{phang}
{opt one} use a scale of -1 to 1 instead of -2 to 2

{phang}
{opt replace} replace the original variable being generated

{marker remarks}{...}
{title:Remarks}

{pstd}
Continuously being updated


{marker examples}{...}
{title:Examples}

{phang}{cmd:. sysuse auto, clear}{p_end}
