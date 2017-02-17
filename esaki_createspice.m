function result=esaki_createspice(r_voltage,r_current)

%step 1, make sure that the orientation is correct!
%you would expect that the "zero" crossing is near from where things go
%negative.  How you take the data is arbitrary.

[~,i_minindex]=min(abs(r_voltage));
i_length=length(r_voltage);
if(i_minindex > i_length/2)
   %flip the data
    a_voltage=-fliplr(r_voltage);
    a_current=-fliplr(r_current);
else
    %data is fine.
    a_voltage=r_voltage;
    a_current=r_current;
end
    if(1)  %plot the original data
        hold on
        plot(a_voltage,a_current);
        hx = graph2d.constantline(0, 'Color',[.7 .7 .7]);
        changedependvar(hx,'x');
        %# horizontal line
        hy = graph2d.constantline(0, 'Color',[.7 .7 .7]);
        changedependvar(hy,'y');
        title('original data');
        xlabel('voltage');
        ylabel('current');
    end
    
    %I need to fit two different lines, start on the left from neg
    a_negvoltage=a_voltage(1:round(i_length/2));
    a_negcurrent=a_current(1:round(i_length/2));
    %now find the max value, and the index.
    [~,i_fitmax]=max((a_negcurrent));
    a_negvoltage_clip=a_voltage(1:i_fitmax);
    a_negcurrent_clip=a_current(1:i_fitmax);
    
   % semilogy(a_negvoltage_clip,a_negcurrent_clip);   
    fit_neg= polyfit(a_negvoltage_clip,(a_negcurrent_clip), 2);
    neg_cur_extract=(polyval(fit_neg, a_voltage));
  %  plot(a_voltage,neg_cur_extract,'r')
    % I now find the maximum of the fit.  This done because I will use the
    % index of the maximum fit to give me the index of from where i should
    % look at the other curve to find a minimum.
    [~,i_fitmax]=max((neg_cur_extract));
  
    %I next do the positive fit, after I find the min.
    a_posvoltage=a_voltage(i_fitmax:end);
    a_poscurrent=a_current(i_fitmax:end);
    [~,i_fitmin]=min((a_poscurrent));
    a_posvoltage_clip=a_posvoltage(i_fitmin:end);
    a_poscurrent_clip=a_poscurrent(i_fitmin:end);
   % hold on;
    plot(a_negvoltage_clip,a_negcurrent_clip,'r',a_posvoltage_clip,a_poscurrent_clip,'g');
    

   
if(1)   
    
    % so the current should be exponential, but it's not due to the merging
    % of current.
    %fit_pos= polyfit(a_posvoltage,log(a_poscurrent), 1);
    %pos_cur_extract=exp(polyval(fit_pos,(a_posvoltage)));
    fit_pos= polyfit(a_posvoltage_clip,(a_poscurrent_clip), 4);
    pos_cur_extract=(polyval(fit_pos,(a_voltage)));
   % plot(a_voltage,pos_cur_extract, 'g')
   % axis([-0.1 0.6 -0.001 0.001]);
    
    %in order to make the best possible simulated fit, I've created a
    %summing algorithm that seems to make some sense.  The algorithm is
    %simple, and designed to keep the general alignment of the curves.  I
    %start by assuming that the data between the min and max is terrible,
    %which is true.  I then find where the derivatives are the opposite of
    %each other.

    i_rightbound_index = length(a_voltage)-length(a_posvoltage_clip);
    i_leftbound_index=length(a_negvoltage_clip);
    fprintf('total length: %i, left: %i, right: %i\n',length(a_voltage),i_leftbound_index,i_rightbound_index);
    %now we look at the derivate of each curve, assuming that the voltage
    %is a UNIFORM step size.    
    dpos = diff((pos_cur_extract))./diff(a_voltage);
    dneg = diff((neg_cur_extract))./diff(a_voltage);
    
    %what wasn't obvious when I wrote this code is that i should limit the
    %search space.  I'm going to bound the search space between 0 and the
    %neg maximum.
    [i_maxvalueneg, i_maxindexneg]=max(neg_cur_extract);
    %find indicies that are valid.
%     for i_count=[1:i_maxindex]
%        if(neg_cur_extract(i_count)<0)
%             i_neg_lowindex=i_count;
%        end
%     end
%     i_neg_lowindex = i_neg_lowindex +1;
    i_neg_lowindex = i_maxindexneg;
    for i_count=[i_maxindexneg:length(neg_cur_extract)]
       if(neg_cur_extract(i_count)>0)
            i_neg_highindex=i_count;
       end
    end
    
    
    [i_maxvaluepos, i_maxindexpos]=min(pos_cur_extract);
    i_pos_highindex = i_maxindexpos;
    i_pos_lowindex=1;
    for i_count=[1:i_maxindexpos]
       if(pos_cur_extract(i_count)<i_maxvalueneg)
            i_pos_lowindex=i_count;
            break;
       end
    end

    
    hold off;
    figure 
    plot(a_voltage,neg_cur_extract,'r',a_voltage,pos_cur_extract,'g')
    %# horizontal line
    hy = graph2d.constantline(0, 'Color',[.7 .7 .7]);
    changedependvar(hy,'y');
    hold on;
    plot(a_voltage(i_neg_lowindex),neg_cur_extract(i_neg_lowindex),'o');
    plot(a_voltage(i_neg_highindex),neg_cur_extract(i_neg_highindex),'o');
    plot(a_voltage(i_pos_lowindex),pos_cur_extract(i_pos_lowindex),'o');
    plot(a_voltage(i_pos_highindex),pos_cur_extract(i_pos_highindex),'o');    
    title('visual confirmation for fit points')
    
    %well, this is terrible. I could not get good way to programmatically
    %find the values where the derivative of each curve is the same.  There
    %should be a nice way to draw a line between curves that shows the best
    %fit; however, it never worked well. Just something to revisit later.
    
%    abs(dpos)-abs(dneg(1))
%    min(abs(abs(dpos)-abs(dneg(1))))
    
%dneg(1)
%dpos(i_pos_lowindex:i_pos_highindex)
%(dpos(i_pos_lowindex:i_pos_highindex))-(dneg(1))
%min((dpos(i_pos_lowindex:i_pos_highindex))-(dneg(1)))
if(0)
    dpos(i_pos_lowindex:i_pos_highindex)
    dneg(i_neg_lowindex:i_neg_highindex)
    abs((dpos(i_pos_lowindex:i_pos_highindex))-(dneg(i_neg_lowindex)))
    [i_val,i_index] = min(abs((dpos(i_pos_lowindex:i_pos_highindex))-(dneg(i_neg_lowindex))))
end
    j=1;
    for i_count=[i_neg_lowindex:i_neg_highindex]
       %the neg and pos should have the same slope 
       [i_val,i_index] = min(abs((dpos(i_pos_lowindex:i_pos_highindex))-(dneg(i_count))));
      % fprintf('(%i):%i %f\n',j,i_index,i_val);
       a_indexofvalue(j)=i_index;
       a_value(j)=i_val;
       j=j+1;
       
    end
   % length(a_value)
   % hold off;
   % figure;plot(a_value);
   % return
   % at this point, we have brute forced the derivatives.  For the index
   % of i_count in dneg, we have corresponding minium value for pos.  So
   % the minimum value in a_value is index of where we should draw a slope
   % to what is in the a_indexofvalue for that index from pos.
   % a_value
   % return
    [i_val,i_index] = min(a_value);
    fprintf('%f %f\n',i_index,(a_indexofvalue(i_index)));
    marker1=i_index;
    marker2=a_indexofvalue(i_index);

   
    hx = graph2d.constantline(a_voltage(marker1), 'Color',[.2 .2 .7]);
    changedependvar(hx,'x');
    hx = graph2d.constantline(a_voltage(marker2), 'Color',[.2 .2 .7]);
    changedependvar(hx,'x');
    axis([-0.1 0.6 -0.001 0.001]);
  
%%% HEY STUPID FIX THIS.    
% This is a total hack.  Something is not working right here 
% The data format is differnet from how it is expected, we should change it
% to have uniform distribution across the code.
    yp2=pos_cur_extract(i_maxindexpos); 
    yp1=neg_cur_extract(i_maxindexneg); 
    xp2=a_voltage(i_maxindexpos); 
    xp1=a_voltage(i_maxindexneg); 
    
    a = (yp2-yp1) / (xp2-xp1);
    b = yp1-a*xp1;
    %y = a*x + b;
    for i_count=i_maxindexneg:i_maxindexpos
       y(i_count)=a*a_voltage(i_count)+b;
        
    end
    a_merge=[neg_cur_extract(1:i_maxindexneg),y(i_maxindexneg+1:i_maxindexpos-1),pos_cur_extract(i_maxindexpos:length(a_voltage))];
    
    fit_diode= polyfit(a_voltage,(a_merge), 7);
    diode_cur_extract=(polyval(fit_diode, a_voltage));    
    %fit_diode
    
    figure 
    hold on
    plot(a_voltage(1:i_maxindexneg),neg_cur_extract(1:i_maxindexneg),'r',a_voltage(i_maxindexpos:length(a_voltage)),pos_cur_extract(i_maxindexpos:length(a_voltage)),'g',a_voltage(i_maxindexneg:i_maxindexpos),y(i_maxindexneg:i_maxindexpos))
    plot(a_voltage,diode_cur_extract,'k--')
    plot(a_voltage(i_neg_lowindex),neg_cur_extract(i_neg_lowindex),'ko');
    plot(a_voltage(i_pos_highindex),pos_cur_extract(i_pos_highindex),'ko');  
    %plot(a_voltage,a_merge, a_voltage,diode_cur_extract,'--')
    grid on;
    title('diode data and extraction fit')
    xlabel('voltage')
    ylabel('current');
    legend('region I data','interpolated data','region III data', 'fit', 'Location','NorthWest')
    axis([-0.1 0.6 -0.001 0.003]);
    hold off;
    %make the spice model
    
    createspice(a_voltage,a_merge, 7)
    

  
end
   
   
end

