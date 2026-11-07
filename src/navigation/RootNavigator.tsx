import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';

import { useAuth } from '../context/AuthContext';
import { LoginScreen } from '../screens/auth/LoginScreen';
import { RegisterScreen } from '../screens/auth/RegisterScreen';
import { PassengerHomeScreen } from '../screens/passenger/PassengerHomeScreen';
import { DriverHomeScreen } from '../screens/driver/DriverHomeScreen';
import { QrScannerScreen } from '../screens/driver/QrScannerScreen';
import { ProfileScreen } from '../screens/profile/ProfileScreen';

import { colors, fontSizes } from '../theme/theme';

const Stack = createNativeStackNavigator();
const Tab = createBottomTabNavigator();

function MainTabNavigator() {
  const { activeRole } = useAuth();

  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarStyle: styles.tabBar,
        tabBarActiveTintColor: colors.primary,
        tabBarInactiveTintColor: colors.textMuted,
        tabBarLabelStyle: { fontWeight: '700', fontSize: 12 },
      }}
    >
      <Tab.Screen
        name="HomeTab"
        component={activeRole === 'sofor' ? DriverHomeScreen : PassengerHomeScreen}
        options={{
          tabBarLabel: activeRole === 'sofor' ? '🚗 İlanlarım & Sürüş' : '🔍 Yolculuk Ara',
          tabBarIcon: ({ color }) => <Text style={{ color, fontSize: 18 }}>{activeRole === 'sofor' ? '🚗' : '🔍'}</Text>,
        }}
      />

      <Tab.Screen
        name="ProfileTab"
        component={ProfileScreen}
        options={{
          tabBarLabel: '👤 Profilim & Ayrıcalıklar',
          tabBarIcon: ({ color }) => <Text style={{ color, fontSize: 18 }}>👤</Text>,
        }}
      />
    </Tab.Navigator>
  );
}

export function RootNavigator() {
  const { user } = useAuth();

  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        {!user ? (
          <>
            <Stack.Screen name="Login" component={LoginScreen} />
            <Stack.Screen name="Register" component={RegisterScreen} />
          </>
        ) : (
          <>
            <Stack.Screen name="Main" component={MainTabNavigator} />
            <Stack.Screen name="QrScanner" component={QrScannerScreen} />
          </>
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
}

const styles = StyleSheet.create({
  tabBar: {
    backgroundColor: colors.surfaceLight,
    borderTopColor: colors.border,
    borderTopWidth: 1,
    height: 60,
    paddingBottom: 8,
    paddingTop: 8,
  },
});
