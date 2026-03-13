import SwiftUI

struct SettingsWindow: View {
    var body: some View {
        TabView {
            SettingsGeneralTab()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            SettingsProgramsTab()
                .tabItem {
                    Label("Programs", systemImage: "cpu")
                }
            SettingsAccountsTab()
                .tabItem {
                    Label("Accounts", systemImage: "wallet.bifold")
                }
        }
    }
}
