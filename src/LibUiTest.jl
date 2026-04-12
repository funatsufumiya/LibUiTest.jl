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
const OnClosingFuncType = Ptr{Cvoid}
const UserData = Ptr{Cvoid}

uiInit=(o)->ccall((:uiInit,libui_lib),Cstring,(Ref{uiInitOptions},),o)
uiFreeInitError=(err)->ccall((:uiFreeInitError,libui_lib),Cvoid,(Cstring,),err)
uiNewWindow=(title, width, height, hasMenuBar)->ccall((:uiNewWindow,libui_lib),uiWindow,(Cstring,Cint,Cint,Cint),title,width,height,hasMenuBar)
uiNewGrid=()->ccall((:uiNewGrid,libui_lib),Ptr{Cvoid},(),)
uiControlShow=(c)->ccall((:uiControlShow,libui_lib),Cvoid,(uiControl,),c)
uiMain=()->ccall((:uiMain,libui_lib),Cvoid,(),)
uiQuit=()->ccall((:uiQuit,libui_lib),Cvoid,(),)
uiUninit=()->ccall((:uiUninit,libui_lib),Cvoid,(),)
uiWindowOnClosing=(win, onClosing, data)->ccall((:uiWindowOnClosing,libui_lib),Cvoid,(Ptr{Cvoid},OnClosingFuncType,UserData),win,onClosing,data)

global already_quitted = false

function onClose(w::uiWindow, data::UserData)::Cint
    global already_quitted = true
    uiQuit()
    return 1
end

function main()
    opt = uiInitOptions(0)
    opt_ptr = Ref(opt)

    err = uiInit(opt)
    if err != C_NULL
        println("Error initializing libui-ng: ", err)
        uiFreeInitError(err)
    end

    w = uiNewWindow("Hello World", 300, 300, 0)
    # grid = uiNewGrid()

    # println("window: ", w)
    # println("grid: ", grid)

    onClosing = @cfunction(onClose, Cint, (uiWindow, UserData))

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
