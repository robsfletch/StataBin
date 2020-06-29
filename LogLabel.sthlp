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
{bf:LogLabel} {hline 2} Generate graphing labels for a log-transformed variable


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:LogLabel}
{cmd:,}
numbers(numlist)
[{it:addone}]
[{it:thousands}]
[{it:abrev}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt numbers}} list of points to label on graph {p_end}
{synopt:{opt local}} name of local variable to save labels in {p_end}
{synopt:{opt addone}} the log variable is log(1+variable) {p_end}
{synopt:{opt thousands}} display label in thousands {p_end}
{synopt:{opt abrev}} use abreviations for thousands (k), millions (M), and Billions (B){p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:LogLabel} Generate graphing labels for a log-transformed


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt numbers} list of points to label on graph

{phang}
{opt local} name of local variable to save labels in

{phang}
{opt addone} the log variable is log(1+variable)

{phang}
{opt thousands} display label in thousands

{phang}
{opt abrev}  use abreviations for thousands (k), millions (M), and Billions (B)

{marker remarks}{...}
{title:Remarks}

{pstd}
Continuously being updated


{marker examples}{...}
{title:Examples}

{phang}{cmd:. sysuse auto, clear}{p_end}
{phang}{cmd:. gen LogPrice = log(1 + price)}{p_end}
{phang}{cmd:. LogLabel , numbers(2000 5000 10000 20000) local(x_lab)}{p_end}
{phang}{cmd:. hist LogPrice, xlabel(`x_lab')}{p_end}

Notice that this pairs nicely with niceloglabels
{phang}{cmd:. sysuse auto, clear}{p_end}
{phang}{cmd:. gen LogPrice = log(1 + price)}{p_end}
{phang}{cmd:. niceloglabels price , local(x_lin_lab) style(125)}{p_end}
{phang}{cmd:. LogLabel , numbers(`x_lin_lab') local(x_lab)}{p_end}
{phang}{cmd:. hist LogPrice, xlabel(`x_lab')}{p_end}
