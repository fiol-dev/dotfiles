#if (${PACKAGE_NAME} && ${PACKAGE_NAME} != "") package ${PACKAGE_NAME} #end
import org.alabuga.builtcontrol.core.domain.error.DataError
import org.alabuga.builtcontrol.core.presentation.configureDefault
import pro.respawn.flowmvi.api.Container
import pro.respawn.flowmvi.api.PipelineContext
import pro.respawn.flowmvi.dsl.lazyStore
import pro.respawn.flowmvi.plugins.recover
import pro.respawn.flowmvi.plugins.reduce

private typealias Ctx =
    PipelineContext<${NAME}State, ${NAME}Intent, ${NAME}Action>

class ${NAME}Container : 
    Container<${NAME}State, ${NAME}Intent, ${NAME}Action> {

    override val store by 
        lazyStore(initial = ${NAME}State()) {
            configureDefault("${NAME}")

            recover {
                updateState { copy(error = DataError.Exception(it.message)) }
                null
            }

            reduce { intent ->
                when (intent) {
                    else -> TODO()
                }
            }
        }
}