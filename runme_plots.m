function runme_plots

data=load('esakiset.mat');
plot(-(data.esaki_sweep25_0uF.voltage-data.esaki_sweep25_0uF.zero),-(smooth(data.esaki_sweep25_0uF.current)),'o');
axis([-0.05 0.5 -0.5e-3 1e-3]);

%# vertical line
%hx = graph2d.constantline(0, 'LineStyle',':', 'Color',[.7 .7 .7]);
hx = graph2d.constantline(0, 'Color',[.7 .7 .7]);
changedependvar(hx,'x');
%# horizontal line
hy = graph2d.constantline(0, 'Color',[.7 .7 .7]);
changedependvar(hy,'y');

title('I-V sweep of esaki diode MBD5057-E28')
xlabel('voltage');
ylabel('current');




end