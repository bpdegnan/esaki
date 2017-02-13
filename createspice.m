function createspice(a_voltage,a_merge)


    fit_diode= polyfit(a_voltage,(a_merge), 7);
    diode_cur_extract=(polyval(fit_diode, a_voltage)); 
    fit_diode_test= polyfit(a_voltage,(a_merge), 5);
    diode_cur_extract_test=(polyval(fit_diode_test, a_voltage)); 
    %fit_diode
    
    figure 
    plot(a_voltage,a_merge, a_voltage,diode_cur_extract,'--', a_voltage,diode_cur_extract_test,':')
    grid on;
    title('diode data and extraction fit')
    xlabel('voltage')
    ylabel('current');
    legend('data', 'fit 7th', 'fit 5rd', 'Location','NorthWest')
    
    %make the spice model
%    SUBCKT MBD1057 1 2
%C1 1 2 0.3E-12
%B1 1 2 I=0.00196*V(1,2)-0.20173*V(1,2)^2+0.48373*V(1,2)^3+1.5996*V(1,2)^4-
%8.4563*V(1,2) ^5+9.6378*V(1,2)^6
%.ENDS

fprintf('\n\n');
fprintf('SUBCKT MBD1057 1 2\n');
fprintf('C1 1 2 0.3E-12\n');
fprintf('B1 1 2 I=');
    fit_diode = fliplr(fit_diode);  %backwards to how spice wants it.
    for i_counter=1:length(fit_diode)
        if(i_counter==1)
            fprintf('%1.5f*V(1,2)',fit_diode(i_counter),i_counter);
        else
            fprintf('%+1.5f*V(1,2)^%i',fit_diode(i_counter),i_counter);

        end
    end
 fprintf('\n');
 fprintf('.END\n');
 
 fprintf('\n\n');
fprintf('SUBCKT MBD1057 1 2\n');
fprintf('C1 1 2 0.3E-12\n');
fprintf('B1 1 2 I=');
    fit_diode = fliplr(fit_diode_test);  %backwards to how spice wants it.
    for i_counter=1:length(fit_diode)
        if(i_counter==1)
            fprintf('%1.5f*V(1,2)',fit_diode(i_counter),i_counter);
        else
            fprintf('%+1.5f*V(1,2)^%i',fit_diode(i_counter),i_counter);

        end
    end
 fprintf('\n');
 fprintf('.END\n');

end