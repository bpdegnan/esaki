function runme

data=load('esakiset.mat');
esaki_sweep25_0uF_0nH=data.esaki_sweep25_0uF;
esaki_sweep25_1uF_0nH=data.esaki_sweep25_1uF;
esaki_sweep25_10uF_0nH=data.esaki_sweep25_10uF;
esaki_sweep25_20uF_0nH=data.esaki_sweep25_20uF;
esaki_sweep25_50uF_0nH=data.esaki_sweep25_50uF;

% plot(esaki_sweep25_0uF_0nH.voltage-esaki_sweep25_0uF_0nH.zero,smooth(esaki_sweep25_0uF_0nH.current));
% hold on;
% plot(esaki_sweep25_1uF_0nH.voltage-esaki_sweep25_1uF_0nH.zero,smooth(esaki_sweep25_1uF_0nH.current));
% plot(esaki_sweep25_10uF_0nH.voltage-esaki_sweep25_10uF_0nH.zero,smooth(esaki_sweep25_10uF_0nH.current));
% %plot(esaki_sweep25_20uF_0nH.voltage-0.764,smooth(esaki_sweep25_20uF_0nH.current));
% plot(esaki_sweep25_50uF_0nH.voltage-esaki_sweep25_50uF_0nH.zero,smooth(esaki_sweep25_50uF_0nH.current));
% hold off;

esaki_sweep25_0uF_6800nH=data.esaki_sweep25_0uF_6800nH;
esaki_sweep25_1uF_6800nH=data.esaki_sweep25_1uF_6800nH;
esaki_sweep25_10uF_6800nH=data.esaki_sweep25_10uF_6800nH;
esaki_sweep25_20uF_6800nH=data.esaki_sweep25_20uF_6800nH;
esaki_sweep25_50uF_6800nH=data.esaki_sweep25_50uF_6800nH;


plot(-(esaki_sweep25_0uF_6800nH.voltage-esaki_sweep25_0uF_6800nH.zero),-(smooth(esaki_sweep25_0uF_6800nH.current)));
hold on;
plot(-(esaki_sweep25_1uF_6800nH.voltage-esaki_sweep25_1uF_6800nH.zero),-(smooth(esaki_sweep25_1uF_6800nH.current)),'r:');
plot(-(esaki_sweep25_10uF_6800nH.voltage-esaki_sweep25_10uF_6800nH.zero),-(smooth(esaki_sweep25_10uF_6800nH.current)),'g--');
%plot(-(esaki_sweep25_20uF_6800nH.voltage-esaki_sweep25_20uF_6800nH.zero),-(smooth(esaki_sweep25_20uF_6800nH.current)),'k');
plot(-(esaki_sweep25_50uF_6800nH.voltage-esaki_sweep25_50uF_6800nH.zero),-(smooth(esaki_sweep25_50uF_6800nH.current)),'c-.');
hold off;
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
legend('0uF','1uF','10uF','50uF', 'Location', 'NorthWest')

esaki_createspice(esaki_sweep25_50uF_6800nH.voltage-esaki_sweep25_50uF_6800nH.zero,(esaki_sweep25_50uF_6800nH.current));
test=esaki_sweep25_50uF_6800nH;
esaki_createspicespline(test.voltage-test.zero,(test.current));

end
