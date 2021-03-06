;*************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;*************************************************************

;______ From Mark Decker's code ______
setvalues NhlGetWorkspaceObjectId()
  "wsMaximumSize" : 5000000000 ;
end setvalues
;_____________________________________

begin

flt_path = "/g/data/w35/Shared_data/AWAP_raw_data/awap_rad_MJ_day/"
flt1     = "bom_awap_daily_rad_1990-1999/"
flt2     = "/bom-rad-day-"
flt3     = "bom_awap_climatology_rad_1990-1999/"
flt4     = "bom_awap_daily_rad_1970-1989/"

;***************** �� �� *******************
year_s = 1990
year_e = 1999
year_sum = year_e-year_s+1
print_clim = False

;___________________________ AWAP flt input ___________________________
var_day = new((/366,681,841/),float)
var_day = 0.0
var_day@_FillValue = -999.

do year = year_s,year_e
    i = 0
    print("year = " +year)
    if ( mod(year,4) .eq. 0) then
       dom = (/31,29,31,30,31,30,31,31,30,31,30,31/)
    else
       dom = (/31,28,31,30,31,30,31,31,30,31,30,31/)
    end if

    do month = 1,12
      do day = 1,dom(month-1)
        if (month .eq. 2) .and. (day .eq. 28) .and. (dom(month-1) .eq. 28) then
          print("no leap")
          fltname = flt_path+flt1+flt2+year+sprinti("%0.2i",month)+sprinti("%0.2i",day)+\
                    "-"+year+sprinti("%0.2i",month)+sprinti("%0.2i",day)+".flt"
          tmp = fbindirread(fltname,0,(/681,841/),"float")
          var_day(i,:,:) = var_day(i,:,:) + tmp
          delete(tmp)
          delete(fltname)
          i = i + 2
        else
          fltname = flt_path+flt1+flt2+year+sprinti("%0.2i",month)+sprinti("%0.2i",day)+\
                    "-"+year+sprinti("%0.2i",month)+sprinti("%0.2i",day)+".flt"
          tmp = fbindirread(fltname,0,(/681,841/),"float")
          var_day(i,:,:) = var_day(i,:,:) + tmp
          delete(tmp)
          delete(fltname)
          i = i + 1
        end if
      end do ; day
    end do ; month
end do ; year

var_day(0:58,:,:) = var_day(0:58,:,:)/year_sum
var_day(59,:,:) = var_day(59,:,:)/2
var_day(60:,:,:) = var_day(60:,:,:)/year_sum

if print_clim .eq. True then

  i = 0
  dom = (/31,29,31,30,31,30,31,31,30,31,30,31/)
  do month = 1,12
    do day = 1,dom(month-1)
      fltname = flt_path+flt3+flt2+"climatology-"+sprinti("%0.2i",month)+sprinti("%0.2i",day)+\
                  "-"+sprinti("%0.2i",month)+sprinti("%0.2i",day)+".flt"
      fbinwrite(fltname, var_day(i,:,:))
      i = i +1
      delete(fltname)
    end do
  end do

else

  do year = 1970,1989
    i = 0
    print("year = " +year)
    if ( mod(year,4) .eq. 0) then
       dom = (/31,29,31,30,31,30,31,31,30,31,30,31/)
    else
       dom = (/31,28,31,30,31,30,31,31,30,31,30,31/)
    end if

    do month = 1,12
      do day = 1,dom(month-1)
        if (month .eq. 2) .and. (day .eq. 28) .and. (dom(month-1) .eq. 28) then
          fltname = flt_path+flt4+flt2+year+sprinti("%0.2i",month)+sprinti("%0.2i",day)+\
                    "-"+year+sprinti("%0.2i",month)+sprinti("%0.2i",day)+".flt"
          fbinwrite(fltname, var_day(i,:,:))
          delete(fltname)
          i = i + 2
        else
          fltname = flt_path+flt4+flt2+year+sprinti("%0.2i",month)+sprinti("%0.2i",day)+\
                    "-"+year+sprinti("%0.2i",month)+sprinti("%0.2i",day)+".flt"
          fbinwrite(fltname, var_day(i,:,:))
          delete(fltname)
          i = i +1
        end if
      end do
    end do
  end do
end if

;_____________________________ PLOT ___________________________________
pic = "check_AWAP_rad_climatology"

wks = gsn_open_wks("pdf",pic)
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")

res                    = True
res@cnFillMode         = "RasterFill"            ; Raster Mode
res@cnFillOn           = True                            ;��ɫ
res@tmBorderThicknessF = 3.0

res@gsnDraw            = True  ; Don't draw plots
res@gsnFrame           = True  ; ����ҳ
res@lbLabelBarOn       = True

;************** ����labelbar ***************
res@lbBoxLinesOn       = True                       ;�ر�lbar box ����
res@lbTitleFont        = 25
res@lbLabelFont        = 25
res@lbTitleFontHeightF = 0.013
res@lbLabelFontHeightF = 0.013
res@txString           = ""
res@tmXBLabelFont      = 25 ;Sets the font index for the bottom X-Axis labels.
res@tmYLLabelFont      = 25

;*************** ���õ�ֵ�� *****************
res@cnLinesOn          = False                       ; �رյ�ֵ������
res@cnLineColor        = "black"
res@cnLineThicknessF   = 1.5
res@cnLineLabelsOn     = False
res@gsnMaximize        = True
res@cnExplicitLabelBarLabelsOn = True   ;?
res@cnLevelSelectionMode = "ExplicitLevels"


levels = (/0.,2.,4.,6.,8.,10.,12.,14.,16.,18.,20.,22.,24.,26.,28.,30.,32.,34.,36./)
res@cnLevels = levels

plot = gsn_csm_contour(wks,var_day(58,:,:),res)
plot = gsn_csm_contour(wks,var_day(59,:,:),res)
plot = gsn_csm_contour(wks,var_day(365,:,:),res)

fltname = flt_path+flt4+flt2+"19800229-19800229.flt"
tmp = fbindirread(fltname,0,(/681,841/),"float")
tmp@_FillValue = -999.
plot = gsn_csm_contour(wks,tmp,res)
delete(tmp)
delete(fltname)

fltname = flt_path+flt4+flt2+"19801231-19801231.flt"
tmp = fbindirread(fltname,0,(/681,841/),"float")
tmp@_FillValue = -999.
plot = gsn_csm_contour(wks,tmp,res)
delete(tmp)
delete(fltname)

fltname = flt_path+flt1+flt2+"19991231-19991231.flt"
tmp = fbindirread(fltname,0,(/681,841/),"float")
tmp@_FillValue = -999.
plot = gsn_csm_contour(wks,tmp,res)
delete(tmp)
delete(fltname)


fltname = flt_path+flt1+flt2+"19901231-19901231.flt"
tmp = fbindirread(fltname,0,(/681,841/),"float")
tmp@_FillValue = -999.
plot = gsn_csm_contour(wks,tmp,res)
delete(tmp)
delete(fltname)


fltname = flt_path+flt1+flt2+"19921231-19921231.flt"
tmp = fbindirread(fltname,0,(/681,841/),"float")
tmp@_FillValue = -999.
plot = gsn_csm_contour(wks,tmp,res)
delete(tmp)
delete(fltname)

fltname = flt_path+flt1+flt2+"19941231-19941231.flt"
tmp = fbindirread(fltname,0,(/681,841/),"float")
tmp@_FillValue = -999.
plot = gsn_csm_contour(wks,tmp,res)
delete(tmp)
delete(fltname)

fltname = flt_path+flt1+flt2+"19961231-19961231.flt"
tmp = fbindirread(fltname,0,(/681,841/),"float")
tmp@_FillValue = -999.
plot = gsn_csm_contour(wks,tmp,res)
delete(tmp)
delete(fltname)

fltname = flt_path+flt1+flt2+"19991231-19991231.flt"
tmp = fbindirread(fltname,0,(/681,841/),"float")
tmp@_FillValue = -999.
plot = gsn_csm_contour(wks,tmp,res)
delete(tmp)
delete(fltname)
end
