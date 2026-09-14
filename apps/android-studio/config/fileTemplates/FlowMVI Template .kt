#if (${PACKAGE_NAME} && ${PACKAGE_NAME} != "") package ${PACKAGE_NAME} #end
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import org.koin.compose.koinInject
import pro.respawn.flowmvi.api.IntentReceiver
import pro.respawn.flowmvi.compose.dsl.subscribe
import pro.respawn.flowmvi.compose.preview.EmptyReceiver

@Composable
fun ${NAME}Screen(
    modifier: Modifier = Modifier,
    container: ${NAME}Container = koinInject(),
) =
    with(container.store) {
        val state by subscribe()

        ${NAME}ScreenContent(state, modifier)
    }

@Composable
private fun IntentReceiver<${NAME}Intent>.${NAME}ScreenContent(
    state: ${NAME}State,
    modifier: Modifier = Modifier,
) {
    when (state) {
        else -> TODO()
    }
}

@Composable
@Preview
private fun ${NAME}ScreenPreview() = EmptyReceiver {
    ${NAME}ScreenContent(TODO())
}