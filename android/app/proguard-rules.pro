# Shared Preferences looks up these Kotlin types through JNI
-keep,allowoptimization interface kotlin.coroutines.Continuation { *; }
-keep,allowoptimization class kotlin.Unit { *; }
-keep,allowoptimization class kotlin.jvm.internal.DefaultConstructorMarker { *; }
-keep,allowoptimization class kotlin.Result { *; }
-keep,allowoptimization class kotlin.Result$Failure { *; }
-keep,allowoptimization class kotlin.coroutines.intrinsics.CoroutineSingletons { *; }
-keep,allowoptimization class kotlin.coroutines.intrinsics.IntrinsicsKt** { *; }
