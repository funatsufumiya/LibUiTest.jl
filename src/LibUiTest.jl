module LibUiTest

libui_lib = "libui.so"

@static if Sys.iswindows()
   libui_lib = "libui.dll"
elseif Sys.isapple()
   libui_lib = "libui.dylib"
else
   libui_lib = "libui.so"
end

mutable struct uiInitOptions 
    Size::Csize_t
end

const uiWindow = Ptr{Cvoid}
const uiControl = Ptr{Cvoid}
const uiButton = Ptr{Cvoid}
const uiGrid = Ptr{Cvoid}
const OnClosingFuncType = Ptr{Cvoid}
const UserData = Ptr{Cvoid}

const uiAlign = Cint
uiAlignFill::Cint = 0
uiAlignStart::Cint = 1
uiAlignCenter::Cint = 2
uiAlignEnd::Cint = 3

uiInit=(o)->ccall((:uiInit,libui_lib),Cstring,(Ref{uiInitOptions},),o)
uiFreeInitError=(err)->ccall((:uiFreeInitError,libui_lib),Cvoid,(Cstring,),err)
uiNewWindow=(title, width, height, hasMenuBar)->ccall((:uiNewWindow,libui_lib),uiWindow,(Cstring,Cint,Cint,Cint),title,width,height,hasMenuBar)
uiNewGrid=()->ccall((:uiNewGrid,libui_lib),Ptr{Cvoid},(),)
uiControlShow=(c)->ccall((:uiControlShow,libui_lib),Cvoid,(uiControl,),c)
uiGridSetPadded=(grid, pad)->ccall((:uiGridSetPadded,libui_lib),Cvoid,(uiControl,Cint),grid,pad)
uiNewButton=(s)->ccall((:uiNewButton,libui_lib),uiControl,(Cstring,),s)
uiWindowSetChild=(win, c)->ccall((:uiWindowSetChild,libui_lib),Cvoid,(uiWindow, uiControl,),win,c)
uiMain=()->ccall((:uiMain,libui_lib),Cvoid,(),)
uiQuit=()->ccall((:uiQuit,libui_lib),Cvoid,(),)
uiUninit=()->ccall((:uiUninit,libui_lib),Cvoid,(),)
uiWindowOnClosing=(win, onClosing, data)->ccall((:uiWindowOnClosing,libui_lib),Cvoid,(Ptr{Cvoid},OnClosingFuncType,UserData),win,onClosing,data)
uiButtonOnClicked=(c, func, data)->ccall((:uiButtonOnClicked,libui_lib),Cvoid,(Ptr{Cvoid},Ptr{Cvoid},UserData),c,func,data)
uiMsgBox=(win,msg1,msg2)->ccall((:uiMsgBox,libui_lib),Cvoid,(uiWindow, Cstring, Cstring),win,msg1,msg2)
uiGridAppend=(g,c,left,top,xspan,yspan,hexpand,halign,vexpand,valign)->ccall((:uiGridAppend,libui_lib),Cvoid,(uiGrid, uiControl, Cint, Cint, Cint, Cint, Cint, uiAlign, Cint, uiAlign),g,c,left,top,xspan,yspan,hexpand,halign,vexpand,valign)

global already_quitted = false
global w::uiWindow

function onClose(w::uiWindow, data::UserData)::Cint
    global already_quitted = true
    uiQuit()
    return 1
end

function onMsgBoxClick(b::uiButton, data::UserData)
	uiMsgBox(w,
	    "This is a normal message box.",
		"More detailed information can be shown here.")
end

function julia_main()
    try
        main()
    catch
        Base.invokelatest(Base.display_error, Base.catch_stack())
        return 1
    end
    return 0
end

function main()
    opt = uiInitOptions(0)
    # opt_ptr = Ref(opt)

    err = uiInit(opt)
    if err != C_NULL
        println("Error initializing libui-ng: ", err)
        uiFreeInitError(err)
    end

    onClosing = @cfunction(onClose, Cint, (uiWindow, UserData))
    onMsgBoxClicked = @cfunction(onMsgBoxClick, Cvoid, (uiControl, UserData))

    global w = uiNewWindow("Hello World", 300, 300, 0)
    grid = uiNewGrid()
    uiGridSetPadded(grid, 1)

    button = uiNewButton("Message Box")
    uiButtonOnClicked(button, onMsgBoxClicked, C_NULL);

    uiGridAppend(grid, button,
		0, 0, 1, 1,
		0, uiAlignFill, 0, uiAlignFill);

    uiWindowSetChild(w, grid);
    # uiWindowSetChild(w, button);

    # println("window: ", w)
    # println("grid: ", grid)

    uiWindowOnClosing(w, onClosing, C_NULL);
    uiControlShow(w)

    try
        uiMain()
    finally
        # println("already_quitted: ", (already_quitted))
        if !(already_quitted)
            uiUninit()
        end
    end
end

end # module LibUiTest
