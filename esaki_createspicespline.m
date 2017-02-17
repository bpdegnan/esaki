function result=esaki_createspicespline(r_voltage,r_current)


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
    if(0)  %plot the original data
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
        hold off;
    end
    
    [a_voltage_ordered, indexsortorder]=sort(a_voltage);  %real data is noisy
    a_current_ordered=a_current(indexsortorder);
    %figure, plot(a_voltage_ordered,a_current_ordered);title('sorted data test');
    a_voltage=a_voltage_ordered;
    a_current=a_current_ordered;
    
    %I need to fit two different lines, start on the left from neg
    a_negvoltage=a_voltage(1:round(i_length/2));
    a_negcurrent=a_current(1:round(i_length/2));
    %now find the max value, and the index.
    [~,i_fitmax]=max((a_negcurrent));
    a_negvoltage_clip=a_voltage(1:i_fitmax);
    a_negcurrent_clip=a_current(1:i_fitmax);
    
    %I have the relative maximum, so now do a curve fit because I want to
    %extend beyond the relative maximum.  2nd degree is a good appoximation
    %in this case because the behavior of the region is similar to a
    %quadratic even though this is not true to the physics. 
    fit_neg= polyfit(smooth(a_negvoltage_clip),smooth(a_negcurrent_clip), 4);

    a_negvoltage_ordered=sort(a_negvoltage);
    neg_cur_extract=(polyval(fit_neg, a_negvoltage_ordered));
    %this plot shows the fit
%    figure,plot(a_negvoltage,a_negcurrent,a_negvoltage_ordered,neg_cur_extract,'r');
    %now that we have a curve, and a fit, we look at the difference between
    %the curve and the fit. I will smooth the data so that the real data
    %doesnt cause a sharp change as we are intested in the deviation.
%    a_smooth_negvoltge=smooth(a_negvoltage);  %smooth for the difference
    a_smooth_negcurrent=smooth(a_negcurrent); %smooth for the difference
%    a_negcurrentextract=(polyval(fit_neg, a_smooth_negvoltge));
    a_negdiff=(a_smooth_negcurrent-smooth(neg_cur_extract));
%    figure,plot(a_smooth_negvoltge,(a_negdiff)); title('difference of current');
    
    % due to the nature of the fit, we can just take the maximum difference
    % from 1:i_fitmax
    [~,i_fitnegthreshold]=max(a_negdiff(1:i_fitmax));
    neg_threshold=a_negdiff(i_fitnegthreshold)*2.0;  %value at the index
    % now we find where we exceed that threshold.
    tmpindex=find(a_negdiff(i_fitmax:end)>neg_threshold,1);
    i_fitnegthreshold=tmpindex+i_fitmax;  %add the search offset
    
    %%%%
    % i_fitnegthreshold, at this point, this is our index for the fits.
    %%%%
    
    %now on to the positive components of the fit
    a_posvoltage=a_voltage(i_fitmax:end);
    a_poscurrent=a_current(i_fitmax:end);
    [~,i_fitmin]=min((a_poscurrent));
    a_posvoltage_clip=a_posvoltage(i_fitmin:end);
    a_poscurrent_clip=a_poscurrent(i_fitmin:end);
    
    a_posvoltage_ordered=sort(a_posvoltage);
    
    fit_pos=polyfit(a_posvoltage_clip,log(a_poscurrent_clip),3);
    a_poscurrentextract=exp(polyval(fit_pos, a_posvoltage_ordered));
    [~,i_fitminpos]=min((a_poscurrentextract));  %this is the relative minimum
   
    %now to look for the relative change
    a_smooth_posvoltage=smooth(a_posvoltage);
    a_smooth_poscurrent=smooth(a_poscurrent,15);
    a_smooth_extract=exp(polyval(fit_pos, a_smooth_posvoltage));
    [~,i_fitminposextract]=min((a_smooth_extract));
    %figure,plot(a_smooth_posvoltage,a_smooth_poscurrent,a_smooth_posvoltage,a_smooth_extract,a_smooth_posvoltage(i_fitminposextract),a_smooth_extract(i_fitminposextract),'bo' ); title('difference of positive current');

    %find the greatest difference
    poscurrent_diff=a_smooth_poscurrent-a_smooth_extract;
  %  figure,plot(a_smooth_posvoltage,abs(poscurrent_diff));
    %now starting at the minimum point, i_fitminposextract, get the
    %greatest value to the right of that point.
    [mindiffval mindiffindex] = min(poscurrent_diff(i_fitminposextract:end));
    %now to look at the REST from right to left at the point where is min.
    poscurrent_scan=fliplr(poscurrent_diff(1:i_fitminposextract));
    mindiffval=mindiffval*100;
    tmpindex=find(poscurrent_scan>mindiffval,1);
    indexmax=i_fitminposextract-tmpindex;
    figure,plot(a_smooth_posvoltage,a_smooth_poscurrent,a_smooth_posvoltage,a_smooth_extract,a_smooth_posvoltage(i_fitminposextract),a_smooth_extract(i_fitminposextract),'bo',a_smooth_posvoltage(indexmax),a_smooth_extract(indexmax),'ro' ); title('difference of positive current');

    %%%%%
    % fill the gap
    %%%%%
    
    %at this point, have have 4 points to use to fill the gaps in order
    %from left to right on the I-V plot
    %i_fitmax
    %i_fitnegthreshold
    %indexmax
    %i_fitminposextract
    pointindex1=i_fitmax;
    pointindex2=i_fitnegthreshold;
    pointindex3=i_fitmax+indexmax;
    pointindex4=i_fitmax+i_fitminposextract;
    
    
    
    figure,plot(a_voltage,a_current);
    hold on;
    plot(a_voltage(pointindex1),a_current(pointindex1),'ro');
    plot(a_voltage(pointindex2),a_current(pointindex2),'go');
    plot(a_voltage(pointindex3),a_current(pointindex3),'bo');
    plot(a_voltage(pointindex4),a_current(pointindex4),'ko');
    
    %make a synthetic point to help with the shape
    pointdiff=abs(pointindex1-pointindex2);
    pointdiff2=abs(pointindex3-pointindex4);
    %make a new set as the interpolated data.
    fitgap_voltage=[a_voltage(pointindex1) a_voltage(pointindex1+pointdiff)  a_voltage(pointindex2) a_voltage(pointindex3) a_voltage(pointindex3+pointdiff2) a_voltage(pointindex4)];
    fitgap_current=[a_current(pointindex1) a_current(pointindex1+pointdiff)  a_current(pointindex2) a_current(pointindex3) a_current(pointindex3+pointdiff2) a_current(pointindex4)];
    
    fitgap= polyfit(fitgap_voltage,fitgap_current, 3);
    fitgap_voltage=a_voltage(pointindex2:(pointindex4-1));
    fitgap_current=polyval(fitgap, fitgap_voltage);
    plot(fitgap_voltage,fitgap_current,'k');
    hold off;
    
    mergedcurrent=[a_current(1:(pointindex2-1)) fitgap_current a_current(pointindex4:end)];
    %size(mergedcurrent)
    %size(a_voltage)
    
    figure;
    hold on
    plot(a_voltage(1:(pointindex2-1)),a_current(1:(pointindex2-1)),fitgap_voltage,fitgap_current,'r:',a_voltage(pointindex4:end),a_current(pointindex4:end),'b');
    
    fit_diode= polyfit(a_voltage,(mergedcurrent), 7);
    diode_cur_extract=(polyval(fit_diode, a_voltage)); 
  
    %fit_diode
   
    plot(a_voltage,diode_cur_extract,'k--')
    
    plot(a_voltage(pointindex1),a_current(pointindex1),'ko');
    plot(a_voltage(pointindex2),a_current(pointindex2),'ko');
    plot(a_voltage(pointindex3),a_current(pointindex3),'ko');
    plot(a_voltage(pointindex4),a_current(pointindex4),'ko');
    
    grid on;
    title('diode data and extraction fit')
    xlabel('voltage')
    ylabel('current');
    legend('region I data', 'spline fit','region III data','SPICE fit', 'Location','NorthWest')
    axis([-0.1 0.6 -0.001 0.003]);
    hold off
    
    %createspice(a_voltage,mergedcurrent);
 
end



    